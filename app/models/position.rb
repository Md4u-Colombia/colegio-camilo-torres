class Position < ActiveRecord::Base
	validates :name,:position_level_id, presence: true
	belongs_to :position_level
	has_many :users
end
