class Event < ActiveRecord::Base
  has_many :registrants
end