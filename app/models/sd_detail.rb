class SdDetail < ActiveRecord::Base
  validates :name, presence: true
  validates :name, uniqueness: {case_sensitive: true}
  
  has_many :period_notes_details
end
