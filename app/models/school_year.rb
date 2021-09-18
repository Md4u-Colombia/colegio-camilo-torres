class SchoolYear < ActiveRecord::Base

	validates :name,:date_begin,:date_end, presence: true

  	has_many :period_notes_details
  	has_many :student_sub_grades
  	has_many :educational_performances
  	has_many :grade_asignature
end
