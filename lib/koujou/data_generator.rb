module Koujou #:nodoc:
  class DataGenerator

    attr_accessor :required_length, :inclusion_values
    
    def initialize(sequenced, validation)
      @sequenced = sequenced
      # Validation is actually a ActiveRecord::Reflection::MacroReflection
      @validation = validation
      @required_length = nil
      @inclusion_values = nil
    end

    def generate_data_for_column_type
      # So if there was an inclusion passed in for validations_inclusion_of (which is just 
      # an enumberable object), let's just return the first element to ensure the value
      # set is the correct one. Mmmkay?
      return get_first_value_for_inclusion unless @inclusion_values.nil?
      # Sometimes models have a validates_presence_of set, but there's no corresponding 
      # db column. The only example I can think of for this is a user model where the actual
      # column is hashed_password but the model requires the presence of password. So we'll 
      # assume string. This could bite me in the ass later, but we'll see.
      if @validation.active_record.columns_hash.has_key?("#{@validation.name}")
        db_type = @validation.active_record.columns_hash["#{@validation.name}"].type
      else
        db_type = 'string'
      end
      # Since the method names are all based on the db types, we'll just go ahead and
      # dynamically call the appropriate one. 
      send("generate_#{db_type}")
    end
    
    def generate_string
      retval = ''
      # I don't really like all these elsif's but, apparently
      # it's more efficient than the numerous explicit returns
      # we used to have. SEE: http://gist.github.com/160718
      if @validation.name.to_s.match(/email/)
        retval = format_if_sequenced(Faker::Internet.email)     
      elsif @validation.name.to_s == 'first_name'
        retval = format_if_sequenced(Faker::Name.first_name)
      elsif @validation.name.to_s == 'last_name'
        retval = format_if_sequenced(Faker::Name.last_name)
      elsif @validation.name.to_s.match(/login|user_name/)
        retval = format_if_sequenced(Faker::Internet.user_name)
      elsif @validation.name.to_s.match(/city/)
        retval = format_if_sequenced(Faker::Address.city) 
      elsif @validation.name.to_s.match(/state|province/)
        retval = format_if_sequenced(Faker::Address.us_state)
      elsif @validation.name.to_s.match(/zip|postal/)
        retval =  format_if_sequenced(Faker::Address.zip_code)
      else
        # If we don't match any standard stuff, just return a regular bs lorem string comprised of 10 words.
        # 10 is sort of a "magic number" I might make a constant for that.
        standard_text = format_if_sequenced(Faker::Lorem.words(10).to_s)
        # So if there's a length validation set, we need to return just that amount of data.
        retval = @required_length ? standard_text[0..@required_length - 1].to_s : standard_text
      end
      retval
    end
    
    def generate_text
      if @required_length
        # So if there's a length validation set, we need to return just that amount of data.
        Faker::Lorem.paragraph(2).to_s[0..@required_length - 1]
      else
        Faker::Lorem.paragraph.to_s
      end
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
    
    def generate_date
      DateTime.now.to_date
    end
    
    def generate_boolean
      true
    end
          
    protected 
      def generate_number
        # If this is supposed to be sequenced (aka unique), we'll get the next int from the 
        # Sequence class, and randomize that.
        random = rand(999)
        @sequenced ? random + (Sequence.instance.next * rand(2)) : random
      end

      def format_if_sequenced(val)
        @sequenced ? "#{Sequence.instance.next}#{val}" : val
      end
      
      def get_first_value_for_inclusion
        @inclusion_values.first
      end
      
  end
end
