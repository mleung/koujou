require File.dirname(__FILE__) + '/test_helper.rb'

class TestDataGenerator < Test::Unit::TestCase

  context 'on generate' do
    
    setup do
      @validation = mock("ActiveRecord::Reflection::MacroReflection")
      @validation.expects(:active_record).twice.returns(User)
    end
    
    should 'generate a valid int' do
      @validation.expects(:name).twice.returns('age')
      int = Koujou::DataGenerator.new(false, @validation).generate_data_for_column_type
      assert_kind_of Fixnum, int
      assert int > 0
    end

    should 'generate a valid float' do
      @validation.expects(:name).twice.returns('salary')
      float = Koujou::DataGenerator.new(false, @validation).generate_data_for_column_type
      assert_kind_of Float, float
    end
    
    should 'generate a valid string' do
      @validation.expects(:name).times(1..10).returns('name')
      string = Koujou::DataGenerator.new(false, @validation).generate_data_for_column_type
      assert_kind_of String, string
      assert string.size > 0
    end
    
    should 'generate a valid email' do
      @validation.expects(:name).times(1..10).returns('email')
      email = Koujou::DataGenerator.new(false, @validation).generate_data_for_column_type
      assert_match(/\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, email)
    end
    
    should 'genreate valid text field values' do
      @validation.expects(:name).twice.returns('about')
      body = Koujou::DataGenerator.new(false, @validation).generate_data_for_column_type
      assert_not_nil body
    end
    
    should 'generate a valid datetime' do
      @validation.expects(:name).twice.returns('hired_on')
      dt = Koujou::DataGenerator.new(false, @validation).generate_data_for_column_type
      assert_kind_of DateTime, dt
    end
    
    should 'always generate true for booleans' do
      @validation.expects(:name).twice.returns('terms_of_service')
      assert Koujou::DataGenerator.new(false, @validation).generate_data_for_column_type
    end
    
  end
  
  context 'on generate with a required length' do
    setup do
      @validation = mock("ActiveRecord::Reflection::MacroReflection")
      @validation.expects(:active_record).twice.returns(Post)
    end
    
    should 'generate the correct size string with a length passed in' do
      @validation.expects(:name).twice.returns('body')
      data_generator = Koujou::DataGenerator.new(false, @validation)
      data_generator.required_length = 20
      body = data_generator.generate_data_for_column_type
      assert_equal 20, body.size
    end
    
  end
  
  context 'on generate with an inclusion' do
    
    setup do
      @validation = mock("ActiveRecord::Reflection::MacroReflection")
    end
    
    should 'generate the correct string with an inclusion_value passed in' do
      data_generator = Koujou::DataGenerator.new(false, @validation)
      data_generator.inclusion_values = %w(Nissan Subaru)
      make = data_generator.generate_data_for_column_type
      assert_equal 'Nissan', make
    end
    
    should 'generate the correct int with an inclusion_value passed in' do
      data_generator = Koujou::DataGenerator.new(false, @validation)
      data_generator.inclusion_values = (1..3)
      num = data_generator.generate_data_for_column_type
      assert_equal 1, num
    end
    
  end

end