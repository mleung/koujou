module Koujou #:nodoc:
  class DataGenerator

    attr_accessor :required_length
    
    def initialize(sequenced, validation)
      @sequenced = sequenced
      # Validation is actually a ActiveRecord::Reflection::MacroReflection
      @validation = validation
    end

    def generate_data_for_column_type
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
      return format_if_sequenced(Faker::Internet.email)   if @validation.name.to_s.match(/email/)
      return format_if_sequenced(Faker::Name.first_name)  if @validation.name.to_s == 'first_name'
      return format_if_sequenced(Faker::Name.last_name)   if @validation.name.to_s == 'last_name'
      return format_if_sequenced(Faker::Name.user_name)   if @validation.name.to_s.match(/login|user_name/)
      return format_if_sequenced(Faker::Address.city)     if @validation.name.to_s.match(/city/)
      return format_if_sequenced(Faker::Address.us_state) if @validation.name.to_s.match(/state|province/)
      return format_if_sequenced(Faker::Address.zip_code) if @validation.name.to_s.match(/zip|postal/)

      # If we don't match any standard stuff, just return a regular bs lorem string comprised of 5 words.
      standard_text = format_if_sequenced(Faker::Lorem.words(5).to_s)
      # So if there's a length validation set, we need to return just that amount of data.
      standard_text = standard_text[0..@required_length - 1].to_s  if @required_length
      standard_text
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
      
  end
end