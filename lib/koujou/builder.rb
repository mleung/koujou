module Koujou #:nodoc:
  module ActiveRecordExtensions # :nodoc:
    module Builder # :nodoc:

      def self.included(base) # :nodoc:
        base.extend ClassMethods
      end

      module ClassMethods #:nodoc:
      
        def koujou(create = true, attributes = nil)
          generate_instance(create, attributes)
        end
      
        def koujou_build(attributes = nil)
          koujou(false, attributes)
        end
      
        def koujou_create(attributes = nil)
          koujou(true, attributes)
        end

        protected
          def generate_instance(create, attributes)
            # There were a metric ton of AR warnings about instance vars
            # not being initialized when running our specs. This hides those.
            silence_warnings do
              instance = build_model_instance(self, attributes)
              instance.save! if create 
              instance
            end
          end
        
          def build_model_instance(klass, attributes = nil, recursed_from_model = nil)
            # If we pass in a string here for klass instead of a constant
            # we want to convert that. 
            klass = Kernel.const_get(klass) unless klass.respond_to?(:new)
            instance = klass.new
            # Set the models attributes if the user passed them in.
            # This will allow attributes to be set regardless if
            # they're required or not.
            instance.attributes = attributes unless attributes.nil?
            
            set_required_attributes!(instance, attributes)
            set_unique_attributes!(instance, attributes)
            set_length_validated_attributes!(instance, attributes)
            set_inclusion_validated_attributes!(instance, attributes)
            set_confirmation_attributes!(instance, attributes)
            create_associations(instance, recursed_from_model)
            CustomValidation.stub_custom_validations!(instance)

            instance
          end
        
          def set_required_attributes!(instance, attributes)
            instance.class.required_validations.each do |v|
              # We want to skip over setting any required fields if the field
              # should also be unique. We handle that in the set_unique_attributes!
              # method with a sequence. Also, if it's a confirmation field (e.g. password_confirmation)
              # we can skip it, because that gets set below.
              standard_required_attributes(instance, v) do
                # We don't want to set anything if the user passed in data for this field
                # or if this is a validates_presence_of :some_id. The ids will be set
                # when we create the association.
                next if overridden_attribute?(attributes, v.name)
                
                generate_and_set_data(instance, v, false)
              end
            end
          end

          def set_unique_attributes!(instance, attributes)
            instance.class.unique_validations.each do |v| 
              next if overridden_attribute?(attributes, v.name)
              generate_and_set_data(instance, v, true)
            end
          end
          
          # This generates set_length_validated_attributes! and set_inclusion_validated_attributes! methods.
          # They used to look like this:
          #
          # def set_length_validated_attributes!(instance, attributes)
          #   instance.class.length_validations.each do |v|
          #     non_required_attributes(instance, v, attributes) { generate_and_set_data(instance, v, false) }
          #   end
          # end
          #
          # def set_inclusion_of_validated_attributes!(instance, attributes)
          #   instance.class.inclusion_validations.each do |v|
          #     non_required_attributes(instance, v, attributes) { generate_and_set_data(instance, v, false) }
          #   end
          # end
          # I'm sure you see the similarities. 
          %w(length inclusion).each do |validation|
            define_method("set_#{validation}_validated_attributes!") do |instance, attributes|
              instance.class.send("#{validation}_validations").each do |v|
                # Non required attributes are anything that doesn't have validates_presence_of, 
                # validates_uniqueness_of and also anything that hasn't been overriden. These
                # values get set there. So there's no real point in setting them again here. 
                non_required_attributes(instance, v, attributes) { generate_and_set_data(instance, v, false) }
              end
            end
          end

          def set_confirmation_attributes!(instance, attributes)
            instance.class.confirmation_validations.each do |v|
              # This goes in and sets the models confirmation to whatever the corresponding
              # fields value is. (e.g. password_confirmation= password)
              instance.send("#{v.name}_confirmation=", instance.send("#{v.name}"))
            end
          end
          
          def create_associations(instance, recursed_from_model = nil)
            # We loop through all the has_one or belongs_to associations on the current instance 
            # using introspection, and build up and assign some models to each, if the user has 
            # required the id (e.g. requires_presence_of :user_id). So we're only going to build 
            # the minimum requirements for each model. 
            instance.class.reflect_on_all_associations.each do |a|
              # We only want to create the association if the user has required the id field. 
              # This will build the minimum valid requirements. 
              next unless has_required_id_validation?(instance, a)
              # Skip polymorphic associations as we don't know what to build for them
              next if a.options.keys.include?(:polymorphic) && a.options[:polymorphic] == true
              
              if a.macro == :has_one || a.macro == :belongs_to
                # If there's a two way association here (user has_one profile, profile belongs_to user)
                # we only want to create one of those, or it'll recurse forever. That's what the 
                # recursed_from_model does. 
                unless recursed_from_model.to_s == instance.class.to_s.downcase
                  instance.send("#{a.name.to_s}=", build_model_instance(get_assocation_class_name(a), nil, a.name))
                end
              end
              
            end
          end
          
          def get_assocation_class_name(assocation)
            # This condition is used if the class_name option
            # is passed to has_many or has_one. We'll definitely
            # want to use that key instead of the name of the association.
            if assocation.options.has_key?(:class_name)
              klass = assocation.options[:class_name]
            else
              klass = assocation.name.to_s.singularize.classify
            end
          end
          
          def generate_and_set_data(instance, validation, sequenced)
            # Don't set values for polymorphic association fields - if no values are supplied we'll want that to just fall through to validation errors
            return if instance.class.reflect_on_all_associations.select { |a| a.options.keys.include?(:polymorphic) && a.options[:polymorphic] == true }.collect { |a| [:"#{a.name}_id", :"#{a.name}_type"] }.flatten.include?(validation.name)
            data_generator = DataGenerator.new(sequenced, validation)
            data_generator.required_length = get_required_length(instance, validation)
            if has_inclusion_validation?(instance, validation)
              data_generator.inclusion_values = get_inclusion_values(instance, validation)
            end
            instance.send("#{validation.name}=", data_generator.generate_data_for_column_type)
          end
          
          def standard_required_attributes(instance, validation)
            yield unless has_unique_validation?(instance, validation) 
          end
          
          def non_required_attributes(instance, validation, attributes)
            yield unless has_unique_validation?(instance, validation) || has_required_validation?(instance, validation) ||
                    overridden_attribute?(attributes, validation.name)
          end
          
          def overridden_attribute?(attributes, key)
            attributes && attributes.has_key?(key.to_sym)
          end

          # This creates has_unique_validation?, has_length_validation? etc. 
          # We could probably make one method that takes a type, but I'd rather
          # get separate methods for each. Cool?
          %w(unique length required inclusion).each do |v|
            define_method("has_#{v}_validation?") do |instance, validation|
              !instance.class.send("#{v}_validations").select{|u| u.name == validation.name }.empty?
            end
          end
                    
          def get_required_length(instance, validation)
            return unless has_length_validation?(instance, validation)
            
            options = instance.class.length_validations.select{|v| v.name == validation.name }.first.options
            
            retval = nil
            # If the validation is validates_length_of :name, :within => 1..20 (or in, which is an alias),
            # let's just return the minimum value of the range. 
            %w(within in).each do |o| 
              retval = options[o.to_sym].entries.first if options.has_key?(o.to_sym)
              break
            end
            if retval.nil?
              # These other validations should just return the value set.
              %w(is minimum maximum).each do |o| 
                retval = options[o.to_sym] if options.has_key?(o.to_sym)  
                break
              end
            end
            retval
          end
          
          def get_inclusion_values(instance, validation)
            return unless has_inclusion_validation?(instance, validation) 
            options = instance.class.inclusion_validations.select{|v| v.name == validation.name }.first.options
            options[:in]
          end
          
          def has_required_id_validation?(instance, association)
            name = association.options.has_key?(:class_name) ? association.options[:class_name].downcase : association.name
            !instance.class.required_validations.select{|v| v.name.to_s  == "#{name}_id" }.empty?
          end
          
      end
      
    end
  end
end
