require File.dirname(__FILE__) + '/test_helper.rb'

class TestDataGenerator < Test::Unit::TestCase

  context 'on generate' do
    
    setup do
      @validation = mock("ActiveRecord::Reflection::MacroReflection")
      @validation.expects(:active_record).returns(User)
    end
    
    should 'generate a valid int' do
      @validation.expects(:name).returns('age')
      int = Kojo::DataGenerator.new(false).generate_data_for_column_type(@validation)
      assert_kind_of Fixnum, int
      assert int > 0
    end

    should 'generate a valid float' do
      @validation.expects(:name).returns('salary')
      float = Kojo::DataGenerator.new(false).generate_data_for_column_type(@validation)
      assert_kind_of Float, float
    end
    
    should  'generate a valid string' do
      @validation.expects(:name).returns('name')
      string = Kojo::DataGenerator.new(false).generate_data_for_column_type(@validation)
      assert_kind_of String, string
      assert string.size > 0
    end
    
    should 'generate a valid datetime' do
      @validation.expects(:name).returns('hired_on')
      dt = Kojo::DataGenerator.new(false).generate_data_for_column_type(@validation)
      assert_kind_of DateTime, dt
    end
    
  end

end