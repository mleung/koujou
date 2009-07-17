class User < ActiveRecord::Base
  validates_presence_of :name, :age, :salary, :hired_on, :email, :first_name, :last_name
  validates_uniqueness_of :name
  
  has_many :posts
  
end