class User < ActiveRecord::Base
  validates_presence_of :name, :age, :salary, :hired_on, :email, :first_name, :last_name, :password
  validates_uniqueness_of :name
  validates_confirmation_of :password
  validates_acceptance_of :terms_of_service
  validates_length_of :password, :within => 5..40, :if => :password_required?
  
  has_many :posts
  has_one :profile
  
  attr_accessible :password, :password_confirmation
  
  def password_required?
    true
  end
  
  
end