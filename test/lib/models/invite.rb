class Invite < ActiveRecord::Base
  validates_presence_of :type
end

class EventInvite < Invite
end

class GroupInvite < Invite
end
