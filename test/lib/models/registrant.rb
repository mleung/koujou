class Registrant < ActiveRecord::Base
  belongs_to :event
  validates_presence_of :event_id
end