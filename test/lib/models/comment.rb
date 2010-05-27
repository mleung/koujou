class Comment < ActiveRecord::Base
  validates_presence_of :bod
  validates_length_of :bod, :maximum => 200
  validates_presence_of :commentable_id, :commentable_type
  
  belongs_to :post
  belongs_to :commentable, :polymorphic => true
end
