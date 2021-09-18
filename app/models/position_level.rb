class PositionLevel < ActiveRecord::Base
	validates :name, presence: true
	has_many :positions
end
