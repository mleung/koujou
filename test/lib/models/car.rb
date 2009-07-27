class Car < ActiveRecord::Base
  belongs_to :owner, :class_name => 'User'
  validates_presence_of :make, :model, :user_id
  
  validates_inclusion_of :make, :in => %w(Nissan Subaru)
  validates_inclusion_of :year, :in => 1900..2009
end