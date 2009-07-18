class Post < ActiveRecord::Base
  validates_presence_of :name
  validates_length_of :body, :is => 20
  
  belongs_to :user
  has_many :comments
end