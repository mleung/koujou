# FIXME: We should probably only duck punch this in if it's the test environment. Figure that out. 

module Kojo #:nodoc:
  module ActiveRecordExtensions # :nodoc:
    module Builder # :nodoc:

      def self.included(base) # :nodoc:
        base.extend ClassMethods
      end

      module ClassMethods #:nodoc:
      
        def kojo(create = true)
          generate_instance(create)
        end
      
        def new_kojo
          kojo(false)
        end
      
        def create_kojo
          kojo(true)
        end

        protected
          def generate_instance(create)
            instance = build_model_instance
            instance.save if create
            instance
          end
        
          def build_model_instance
            instance = self.new
            set_required_attributes!(instance)
            set_unique_attributes!(instance)
            create_associations(instance)
            instance
          end
        
          def set_required_attributes!(instance)
            self.required_validations.each do |m|
              # We want to skip over setting any required fields if the field
              # should also be unique. We handle that in the set_unique_attributes!
              # method with a sequence.
              next if !self.unique_validations.select{|v| v.name == m.name }.empty?
              # Set test data for every required column. Test data is based on the column name,
              # prepended with test.
              instance.send("#{m.name}=", generate_data_for_column_type(m))
            end
          end

          # This queries the base class for anything
          # that has a uniqueness_of validation.
          # We need to sequence those fields, so 
          # all the data we generate is unique.
          def set_unique_attributes!(instance)
            self.unique_validations.each { |m| instance.send("#{m.name}=", generate_data_for_column_type(m, true)) }
          end

          def create_associations(instance)
          end
          
          def generate_data_for_column_type(validation, sequenced = false)
            db_type = validation.active_record.columns_hash["#{validation.name}"].type
            case db_type
            when :text
              sequenced ? "test_#{validation.name}_#{Sequence.instance.next}" : "text_#{validation.name}"
            when :integer
              
            end
          end
      end
      
    end
  end
end
