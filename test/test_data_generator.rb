require File.dirname(__FILE__) + '/test_helper.rb'

class TestDataGenerator < Test::Unit::TestCase

  context 'on generate' do
    
    setup do
      @validation = mock("ActiveRecord::Reflection::MacroReflection")
      @validation.expects(:active_record).returns(User)
    end
    
    should 'generate a valid int' do
      @validation.expects(:name).returns('age')
      int = Koujou::DataGenerator.new(false, @validation).generate_data_for_column_type
      assert_kind_of Fixnum, int
      assert int > 0
    end

    should 'generate a valid float' do
      @validation.expects(:name).returns('salary')
      float = Koujou::DataGenerator.new(false, @validation).generate_data_for_column_type
      assert_kind_of Float, float
    end
    
    should 'generate a valid string' do
      @validation.expects(:name).times(1..4).returns('name')
      string = Koujou::DataGenerator.new(false, @validation).generate_data_for_column_type
      assert_kind_of String, string
      assert string.size > 0
    end
    
    should 'generate a valid email' do
      @validation.expects(:name).times(1..4).returns('email')
      email = Koujou::DataGenerator.new(false, @validation).generate_data_for_column_type
      assert_match /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, email
    end
    
    should 'generate a valid datetime' do
      @validation.expects(:name).returns('hired_on')
      dt = Koujou::DataGenerator.new(false, @validation).generate_data_for_column_type
      assert_kind_of DateTime, dt
    end
    
    should 'always generate true for booleans' do
      @validation.expects(:name).returns('terms_of_service')
      assert Koujou::DataGenerator.new(false, @validation).generate_data_for_column_type
    end
    
  end

end