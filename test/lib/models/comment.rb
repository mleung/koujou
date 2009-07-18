class Comment < ActiveRecord::Base
  validates_presence_of :body
  validates_length_of :body, :minium => 100, :maximum => 200
  
  belongs_to :post
  
end