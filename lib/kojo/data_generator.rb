module Kojo #:nodoc:
  class DataGenerator
    
    def initialize(sequenced, validation)
      @sequenced = sequenced
      # Validation is actually a ActiveRecord::Reflection::MacroReflection
      @validation = validation
    end

    def generate_data_for_column_type
      db_type = @validation.active_record.columns_hash["#{@validation.name}"].type
      # Since the method names are all based on the db types, we'll just go ahead and
      # dynamically call all those. 
      send("generate_#{db_type}")
    end
    
    def generate_string
      # FIXME: This is going to get nasty quick. Refactor.
      return format_if_sequenced(Faker::Internet.email) if @validation.name =~ /email+?/
      return format_if_sequenced(Faker::Name.first_name) if @validation.name == 'first_name'
      return format_if_sequenced(Faker::Name.last_name) if @validation.name == 'last_name'
      # If we don't match any standard stuff, just return a regular string.
      bs = Faker::Company.bs
      @sequenced ? "#{bs}_#{Sequence.instance.next}" : bs
    end
    
    def generate_text
      Faker::Lorem.paragraph
    end
    
    def generate_integer
      generate_number
    end
    
    def generate_float
      generate_number.to_f
    end
    
    def generate_datetime
      DateTime.now
    end
          
    protected 
      def generate_number
        # If this is supposed to be sequenced (aka unique), we'll get the next int from the 
        # Sequence class, and randomize that.
        random = rand(999)
        @sequenced ? random + (Sequence.instance.next * rand(2)) : random
      end

      def format_if_sequenced(val)
        @sequenced ? "#{val} #{Sequence.instance.next}" : val
      end
      
  end
end