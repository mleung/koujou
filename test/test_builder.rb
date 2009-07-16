require File.dirname(__FILE__) + '/test_helper.rb'

class TestBuilder < Test::Unit::TestCase

  # Gives us DB access.
  ActiveRecordTestConnector.setup

  context 'ActiveRecord' do

    should 'have the kojo method' do
      assert User.respond_to?(:kojo)
    end
    
    should 'return an instance of User, with ActiveRecord::Base as an ancestor' do
      u = User.kojo
      assert_equal "User", u.class.to_s
      assert u.class.ancestors.include?(ActiveRecord::Base)
    end
  end
  
  context 'on sending the kojo message' do
    
    should 'persist the record to the db without any arguments' do
      u = User.kojo
      assert !u.new_record?
    end
    
    should 'return a new record when passing in false' do
      u = User.kojo(false)
      assert u.new_record?
    end
    
    should 'have unique values for multiple instances where validates_uniqueness_of is defined for a column' do
      u1 = User.kojo
      u2 = User.kojo
      assert_not_equal u1.name, u2.name
    end
    
  end
  
  context 'on sending the create_kojo message' do

    should 'persist the record to the db' do
      u = User.create_kojo
      assert !u.new_record?
    end
    
  end
  
  context 'on sending the new_kojo message' do
    
    should 'reutrn a new record' do
      u = User.new_kojo
      assert u.new_record?
    end
    
  end
  
  context 'on creating associations' do
    
    should 'have a post class associated with a user' do
      u = User.kojo
      assert_equal 1, u.posts.size
    end
    
    should 'generate a comment class associated with posts, which is associated with users' do
      u = User.create_kojo
      assert_equal 1, u.posts.first.comments.size
    end
    
  end
  
end



