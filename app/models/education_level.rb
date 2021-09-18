class EducationLevel < ActiveRecord::Base
  has_many :grades
	validates :name, presence: true
	validates :name, uniqueness: true
end
