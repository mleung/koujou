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
    
    should 'have the same value for password_confirmation as password' do
      u = User.koujou
      assert_equal u.password, u.password_confirmation
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
      p = Post.koujou
      c = Comment.koujou_create(:bod => comment, :commentable_id => p.id, :commentable_type => p.class.name)
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
    
    should 'allow me to override the model attributes' do
      clever = 'Whatever\'s clever'
      p = Post.koujou_build(:name => clever)
      assert_equal clever, p.name
    end

    should 'cause a model to be invalid if you override a field that has validates_presence_of with a nil value' do
      u = User.koujou_build(:email => nil)
      assert !u.valid?
    end
  end
  
  context 'associations' do
    
    should 'not automatically create any assoications unless there\'s a validation for the id' do
      u = User.koujou
      assert_equal 0, u.posts.size
    end
    
    should 'automatically create a user for a profile when the profile has a required user_id validation' do
      p = Profile.koujou
      assert_not_nil p.user
    end
    
    should 'find custom validations' do
      assert_equal 2, User.custom_validations.size
    end
    
    should 'car should have an owner association to user via class_name' do
      c = Car.koujou
      assert_not_nil c.owner
    end
    
  end
  
  context 'custom validations' do
    
    should 'totally override any custom validations, and thus not fail when we call koujou' do
      p = Post.koujou
      assert true
    end
    
  end
  
  context 'inclusion_of_validation' do
    
    should 'create the correct value for an attribute marked with validates_inclusion_of' do
      c = Car.koujou
      assert_equal 'Nissan', c.make
    end
    
    should 'create the correct values for inclusion when it\'s not also a required attribute' do
      c = Car.koujou
      assert_equal 1900, c.year
    end
    
  end

  context "using polymorphic associations" do
    should "leave the association alone and not validate if no values supplied" do
      ex = assert_raise ActiveRecord::RecordInvalid do
        c = Comment.koujou(true, :bod => "test body")
      end
      assert_equal "Validation failed: Commentable can't be blank, Commentable type can't be blank", ex.message
    end

    should "work when supplying the polymorphic fields" do
      p = Post.koujou
      c = Comment.koujou(true, :bod => "test body", :commentable_type => p.class.name, :commentable_id => p.id)
      assert_equal p.id, c.commentable.id
    end
  end

  context "using STI" do
    should "not be setting the type field to something random" do
      @event_invite = EventInvite.koujou
      assert_equal 1, EventInvite.all.length
      assert_equal "EventInvite", @event_invite.reload.type
      @group_invite = GroupInvite.koujou
      assert_equal 1, GroupInvite.all.length
      assert_equal "GroupInvite", @group_invite.reload.type
      assert_equal 2, Invite.all.length
    end
  end
  
end



