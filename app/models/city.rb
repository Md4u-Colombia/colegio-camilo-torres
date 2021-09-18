class City < ActiveRecord::Base
	validates :name,:country_id, presence: true
	belongs_to :country 
	has_many :users
end
