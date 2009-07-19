class Profile < ActiveRecord::Base
  belongs_to :user
  has_many :photos
  
  has_many :sent_messages, :class_name => 'Message', :order => 'created_at desc', :foreign_key => 'sender_id'
  
end