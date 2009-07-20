require File.dirname(__FILE__) + '/test_helper.rb'

class TestBuilder < Test::Unit::TestCase

  # Gives us DB access.
  ActiveRecordTestConnector.setup

  context 'ActiveRecord' do

    should 'have the koujou method' do
      assert User.respond_to?(:koujou)
    end
    
    should 'return an instance of User, with ActiveRecord::Base as an ancestor' do
      u = User.koujou
      assert_equal User, u.class
      assert u.class.ancestors.include?(ActiveRecord::Base)
    end
  end
  
  context 'on sending the koujou message' do
    
    should 'persist the record to the db without any arguments' do
      u = User.koujou
      assert !u.new_record?
    end
    
    should 'return a new record when passing in false' do
      u = User.koujou(false)
      assert u.new_record?
    end
    
    should 'have unique values for multiple instances where validates_uniqueness_of is defined for a column' do
      u1 = User.koujou
      u2 = User.koujou
      assert_not_equal u1.name, u2.name
    end
    
    should 'have a password confirmation automatically set' do
      u = User.koujou
      assert_not_nil u.password_confirmation
    end
    
    should 'allow me to override the model attributes' do
      namae = 'One Factory to Rule them all'
      p = Post.koujou(true, :name => namae)
      assert_equal namae, p.name
    end
    
    should 'allow me to override select attributes, yet still generate data for the rest' do
      # We have a validates_length_of :bod, :is => 20 set.
      bod = "T" * 20
      p = Post.koujou_create(:body => bod)
      assert_not_nil p.name
      assert_equal bod, p.body
    end
        
  end
  
  context 'on sending the koujou_create message' do

    should 'persist the record to the db' do
      u = User.koujou_create
      assert !u.new_record?
    end
    
    should 'allow me to override the model attributes' do
      comment = 'your post is epic fail'
      c = Comment.koujou_create(:bod => comment)
      assert_equal comment, c.bod
    end
    
    should 'not be sequenced unless I say so' do
      u = User.koujou
      # The first digit should not be an integer.
      assert_equal 0, u.first_name[0,1].to_i
    end
    
  end
  
  context 'on sending the koujou_build message' do
    
    should 'return a new record' do
      u = User.koujou_build
      assert u.new_record?
    end
    
    should 'all me to override the model attributes' do
      clever = 'Whatver\'s clever'
      p = Post.koujou_build(:name => clever)
      assert_equal clever, p.name
    end
    
  end
  
  context 'on creating associations' do
    
    setup do
      @u = User.koujou
    end
    
    should 'have a post class associated with a user' do
      assert_equal 1, @u.posts.size
    end
    
    should 'generate a comment class associated with posts, which is associated with users' do
      assert_equal 1, @u.posts.first.comments.size
    end
    
    should 'have a profile through the has_one association' do
      assert_not_nil @u.profile
    end
    
    should 'create the association using the class_name option in has_many' do
      assert_not_nil @u.profile.sent_messages.first
    end
    
    should 'create the parent for model that has belongs to, where the parent does not have a has_many for it' do
      c = Car.koujou
      assert_not_nil c.user
    end
    
  end
  
end



