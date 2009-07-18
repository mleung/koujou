require File.dirname(__FILE__) + '/test_helper.rb'

class TestSequence < Test::Unit::TestCase
  
  context "sequence" do
    
    should "implement the singleton pattern" do
      assert !Koujou::Sequence.respond_to?(:new)
      assert Koujou::Sequence.include?(Singleton)
    end
    
    should "generate successive numbers when calling next" do
      first = Koujou::Sequence.instance.next
      second = Koujou::Sequence.instance.next
      assert_not_equal first, second
    end
    
  end
  
end