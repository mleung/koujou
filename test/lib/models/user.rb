class User < ActiveRecord::Base
  validates_presence_of :name, :age, :salary, :hired_on, :email, :first_name, :last_name, :password
  validates_uniqueness_of :name
  validates_confirmation_of :password
  validates_acceptance_of :terms_of_service
  
  has_many :posts
  has_one :profile
  
  attr_accessible :password, :password_confirmation
  
  
end