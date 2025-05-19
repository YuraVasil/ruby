class Participant < ApplicationRecord
  has_many :event_participants
  has_many :events, through: :event_participants

  validates :name, presence: true
end
