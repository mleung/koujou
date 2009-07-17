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
            klass = Kernel.const_get(klass) unless klass.respond_to?(:new)
            instance = klass.new
            if attributes.nil?
              set_required_attributes!(instance)
              set_unique_attributes!(instance)
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
              # method with a sequence.
              next if !instance.class.unique_validations.select{|u| u.name == v.name }.empty?
              instance.send("#{v.name}=", DataGenerator.generate_data_for_column_type(v))
            end
          end

          def set_unique_attributes!(instance)
            instance.class.unique_validations.each {|v| instance.send("#{v.name}=",
                                                  DataGenerator.generate_data_for_column_type(v, true)) }
          end

          def create_associations(instance)
            # This looks sort of hairy, but it's actually quite simple. We just loop through all the has_many
            # associations on the current instance using introspection, and build up and assign
            # some models to each.
            instance.class.reflect_on_all_associations(:has_many).each do |a|
              instance.instance_eval(a.name.to_s) << build_model_instance(a.name.to_s.singularize.classify) 
            end
          end
                    
      end
      
    end
  end
end
