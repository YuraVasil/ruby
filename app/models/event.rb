class Event < ApplicationRecord
  has_many :event_participants
  has_many :participants, through: :event_participants

  has_many :event_locations
  has_many :locations, through: :event_locations

  validates :name, presence: true
  validates :date, presence: true
end
