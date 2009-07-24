# TODO: We need to override any before_validation, or before_validation_on create callbacks as well, I think.
module Koujou #:nodoc:
  class CustomValidation # :nodoc:
    
    # This just goes in and redefines any custom validation methods. Since we can't
    # really ascertain what the intent of those are when koujou runs, it seems 
    # like stubbing them out is the most logical choice.
    def self.stub_custom_validations!(instance)
      instance.class.custom_validations.each do |v|
        instance.class.module_eval { define_method(v.name.to_s) { true } }
      end
    end

  end
end