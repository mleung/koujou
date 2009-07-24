class User < ActiveRecord::Base
  validates_presence_of :name, :age, :salary, :hired_on, :email, :first_name, :last_name
  validates_uniqueness_of :name
  validates_acceptance_of :terms_of_service

  attr_accessor :password

  
  # This is basically the main validation from restful_auth's user model.
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :email,    :within => 3..100
  
  has_many :posts
  has_one :profile
  
  attr_accessible :email, :password, :password_confirmation
  
  def password_required?
    true
  end
  
  
end