class Comment < ActiveRecord::Base
  validates_presence_of :bod
  validates_length_of :bod, :maximum => 200
  
  belongs_to :post
  
end