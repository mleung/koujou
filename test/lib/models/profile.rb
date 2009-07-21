class Profile < ActiveRecord::Base
  belongs_to :user
  has_many :photos, :order => 'created_at DESC'
  
  has_many :sent_messages, :class_name => 'Message', :order => 'created_at desc', :foreign_key => 'sender_id'
  
  validates_presence_of :user_id
    
end