class User < ActiveRecord::Base
  validates_presence_of :name, :age, :salary, :hired_on, :email, :first_name, :last_name, :password, :terms_of_service
  validates_uniqueness_of :name
  validates_confirmation_of :password
  
  has_many :posts
  has_one :profile
  
  attr_accessible :password, :password_confirmation
  
  
end