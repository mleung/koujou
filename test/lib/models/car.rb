class Car < ActiveRecord::Base
  belongs_to :user
  validates_presence_of :make, :model
  
  validates_inclusion_of :make, :in => %w(Nissan Subaru)
  validates_inclusion_of :year, :in => 1900..2009
end