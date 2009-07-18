# FIXME: We should probably only duck punch this in if it's the test environment. Figure that out. 

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
            instance = build_model_instance(self, attributes)
            instance.save if create 
            instance
          end
        
          def build_model_instance(klass, attributes = nil)
            # If we pass in a string here for klass instead of a constant
            # we want to convert that. 
            klass = Kernel.const_get(klass) unless klass.respond_to?(:new)
            instance = klass.new
            # Set the models attributes if the user passed them in.
            # this will allow attributes to be set regardless if
            # they're required or not.
            instance.attributes = attributes unless attributes.nil?

            set_required_attributes!(instance, attributes)
            set_unique_attributes!(instance, attributes)
            set_confirmation_attributes!(instance, attributes)
            set_length_validated_attributes!(instance, attributes)
            create_associations(instance)

            instance
          end
        
          def set_required_attributes!(instance, attributes)
            instance.class.required_validations.each do |v|
              # We want to skip over setting any required fields if the field
              # should also be unique. We handle that in the set_unique_attributes!
              # method with a sequence. Also, if it's a confirmation field (e.g. password_confirmation)
              # we can skip it, because that gets set below.
              standard_required_attributes(instance, v) do
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
          
          def set_length_validated_attributes!(instance, attributes)
            instance.class.length_validations.each do |v|
              # We also handle length in set_unique_attributes! and set_required_attributes! so
              # no need to worry about it here.
              next if has_unique_validation?(instance, v) || has_required_validation?(instance, v) ||
                      overridden_attribute?(attributes, v.name)
              
              generate_and_set_data(instance, v, false)
            end
          end

          def set_confirmation_attributes!(instance, attributes)
            instance.class.confirmation_validations.each do |v|
              # This goes in and sets the models confirmation to whatever the corresponding
              # fields value is. (e.g. password_confirmation= password)
              instance.send("#{v.name}_confirmation=", instance.send("#{v.name}"))
            end
          end
          
          def create_associations(instance)
            # This looks sort of hairy, but it's actually quite simple. We just loop through all the has_many
            # or has_one associations on the current instance using introspection, and build up and assign
            # some models to each.
            instance.class.reflect_on_all_associations.each do |a|
              # We don't want to create any models for has_many :through =>
              next if a.through_reflection
              
              if a.macro == :has_many
                instance.send(a.name.to_s) << build_model_instance(a.name.to_s.singularize.classify) 
              end
              
              if a.macro == :has_one
                instance.send("#{a.name.to_s}=", build_model_instance(a.name.to_s.singularize.classify))
              end
              
            end
          end
          
          def generate_and_set_data(instance, validation, sequenced)
            data_generator = DataGenerator.new(sequenced, validation)
            data_generator.required_length = get_required_length(instance, validation)
            instance.write_attribute(validation.name, data_generator.generate_data_for_column_type)
          end
          
          def standard_required_attributes(instance, validation)
            yield unless has_unique_validation?(instance, validation) 
          end
          
          def overridden_attribute?(attributes, key)
            attributes && attributes.has_key?(key.to_sym)
          end

          # This creates has_unique_validation?, has_length_validation? etc. 
          # We could probably make one method that takes a type, but I'd rather
          # get separate methods for each. Cool?
          %w(unique length required).each do |v|
            define_method("has_#{v}_validation?") do |instance, validation|
              !instance.class.send("#{v}_validations").select{|u| u.name == validation.name }.empty?
            end
          end
          
          def get_required_length(instance, validation)
            return unless has_length_validation?(instance, validation)
            
            options = instance.class.length_validations.first.options
            # If the validation is validates_length_of :name, :within => 1..20
            # Let's just return the minimum value of the range.
            return options.values.first.entries.first if options.has_key?(:within) || options.has_key?(:in)
            # If any of the other options are set, just return the first value. That should satisfy the validation.
            return options.values.first if options.has_key?(:minimum)  ||
                                        options.has_key?(:maximum) || options.has_key?(:is)
          end
                                      
      end
      
    end
  end
end
