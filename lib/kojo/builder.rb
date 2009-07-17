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
            instance.class.required_validations.each do |m|
              # We want to skip over setting any required fields if the field
              # should also be unique. We handle that in the set_unique_attributes!
              # method with a sequence.
              next if ! instance.class.unique_validations.select{|v| v.name == m.name }.empty?
              instance.send("#{m.name}=", generate_data_for_column_type(m))
            end
          end

          # This queries the base class for anything
          # that has a uniqueness_of validation.
          # We need to sequence those fields, so 
          # all the data we generate is unique.
          def set_unique_attributes!(instance)
            instance.class.unique_validations.each {|m| instance.send("#{m.name}=", generate_data_for_column_type(m, true)) }
          end

          def create_associations(instance)
            # This looks sort of hairy, but it's quite simple. So we take the instance, and turn it into a class.
            # We can't just use self, because this is essentially recursive, and it could be the class in has_many
            # that is calling it. We just get all the has_many associations, then create a corresponding record for
            # them. Done, and done. 
            instance.class.reflect_on_all_associations(:has_many).each do |a|
              instance.instance_eval(a.name.to_s) << build_model_instance(a.name.to_s.singularize.classify) 
            end
          end
          
          # TODO: Throw in the faker gem to generate data.
          def generate_data_for_column_type(validation, sequenced = false)
            db_type = validation.active_record.columns_hash["#{validation.name}"].type
            case db_type
            when :text
              sequenced ? "test_#{validation.name}_#{Sequence.instance.next}" : "test_#{validation.name}"
            when :integer
              
            end
          end
          
      end
      
    end
  end
end
