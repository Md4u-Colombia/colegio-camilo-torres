class EducationalPerformance < ActiveRecord::Base
	validates :school_year_id,:educational_period_id,:grade_id,:educational_asignature_id, presence: true

	has_many :period_notes_details
  belongs_to :educational_asignature
  belongs_to :school_year
  belongs_to :grade
  has_many :student_progresses
  belongs_to :educational_period
  belongs_to :educational_performance_list
end
