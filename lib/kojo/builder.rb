# FIXME: We should probably only duck punch this in if it's the test environment. Figure that out. 

module Kojo #:nodoc:
  module ActiveRecordExtensions # :nodoc:
    module Builder # :nodoc:

      def self.included(base) # :nodoc:
        base.extend ClassMethods
      end

      module ClassMethods #:nodoc:
      
        def kojo(create = true, attributes = nil)
          generate_instance(create, attributes)
        end
      
        def new_kojo(attributes = nil)
          kojo(false, attributes)
        end
      
        def create_kojo(attributes = nil)
          kojo(true, attributes)
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
            if attributes.nil?
              set_required_attributes!(instance)
              set_unique_attributes!(instance)
              set_confirmation_attributes!(instance)
            else
              instance.attributes = attributes
            end
            create_associations(instance)
            instance
          end
        
          def set_required_attributes!(instance)
            instance.class.required_validations.each do |v|
              # We want to skip over setting any required fields if the field
              # should also be unique. We handle that in the set_unique_attributes!
              # method with a sequence. Also, if it's a confirmation field (e.g. password_confirmation)
              # we can skip it, because that gets set below.
              standard_required_attributes(instance, v) do
                instance.send("#{v.name}=", DataGenerator.new(false, v).generate_data_for_column_type)
              end
            end
          end

          def set_unique_attributes!(instance)
            instance.class.unique_validations.each {|v| instance.send("#{v.name}=",
                                                  DataGenerator.new(true, v).generate_data_for_column_type) }
          end

          def set_confirmation_attributes!(instance)
            instance.class.confirmation_validations.each do |v|
              # This goes in and sets the models confirmation to whatever the corresponding
              # fields value is. (e.g. password_confirmation= password)
              instance.send("#{v.name}_confirmation=", instance.send("#{v.name}"))
            end
          end

          def create_associations(instance)
            # This looks sort of hairy, but it's actually quite simple. We just loop through all the has_many
            # associations on the current instance using introspection, and build up and assign
            # some models to each.
            instance.class.reflect_on_all_associations(:has_many).each do |a|
              instance.instance_eval(a.name.to_s) << build_model_instance(a.name.to_s.singularize.classify) 
            end
          end
          
          def standard_required_attributes(instance, validation)
            yield unless has_unique_validation?(instance, validation) 
          end
          
          def has_unique_validation?(instance, validation)
            !instance.class.unique_validations.select{|u| u.name == validation.name }.empty?
          end
                                      
      end
      
    end
  end
end
