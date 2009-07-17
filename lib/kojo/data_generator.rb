module Kojo #:nodoc:
  class DataGenerator
    
    class << self

      def generate_data_for_column_type(validation, sequenced = false)
        # Validation is actually a ActiveRecord::Reflection::MacroReflection
        db_type = validation.active_record.columns_hash["#{validation.name}"].type
        # Since the method names are all based on the db types, we'll just go ahead and
        # dynamically call all those. 
        send("generate_#{db_type}", sequenced)
      end
      
      def generate_string(sequenced)
        bs = Faker::Company.bs
        sequenced ? "#{bs}_#{Sequence.instance.next}" : bs
      end
      
      def generate_text(sequenced)
        Faker::Lorem.paragraph
      end
      
      def generate_integer(sequenced)
        generate_number(sequenced)
      end
      
      def generate_float(sequenced)
        generate_number(sequenced).to_f
      end
      
      def generate_datetime(sequenced)
        DateTime.now
      end
            
      protected 
        def generate_number(sequenced)
          # If this is supposed to be sequenced (aka unique), we'll get the next int from the 
          # Sequence class, and randomize that.
          random = rand(999)
          sequenced ? random + (Sequence.instance.next * rand(2)) : random
        end

    end
    
  end
end