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

                data_generator = DataGenerator.new(false, v)
                instance.write_attribute(v.name, data_generator.generate_data_for_column_type)
              end
            end
          end

          def set_unique_attributes!(instance, attributes)
            instance.class.unique_validations.each do |v| 
              next if overridden_attribute?(attributes, v.name)

              data_generator = DataGenerator.new(true, v)
              instance.write_attribute(v.name, data_generator.generate_data_for_column_type)
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
          
          def standard_required_attributes(instance, validation)
            yield unless has_unique_validation?(instance, validation) 
          end

          def overridden_attribute?(attributes, key)
            attributes && attributes.has_key?(key.to_sym)
          end

          # This creates has_unique_validation?, has_length_validation? etc. 
          # We could probably make one method that takes a type, but I'd rather
          # use define_method and get separate methods for each. Cool?
          %w(unique length).each do |v|
            define_method("has_#{v}_validation?") do |instance, validation|
              !instance.class.send("#{v}_validations").select{|u| u.name == validation.name }.empty?
            end
          end
                                      
      end
      
    end
  end
end
