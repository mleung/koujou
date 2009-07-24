require File.dirname(__FILE__) + '/test_helper.rb'

class TestCustomValidation < Test::Unit::TestCase

  context 'CustomValidation' do
  
    should 'override any custom validations' do
      instance = User.new
      Koujou::CustomValidation.stub_custom_validations!(instance)
      assert instance.custom_validation_method
    end
    
    should 'override any before_validate methods' do
      
    end
    
  end

end