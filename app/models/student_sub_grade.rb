class StudentSubGrade < ActiveRecord::Base
	validates :student_id,:school_year_id,:sub_grade_id, presence: true

	belongs_to :student, :class_name => "User", :foreign_key => "student_id"
	belongs_to :school_year
	belongs_to :sub_grade
	belongs_to :student_grade
	has_many :student_progresses
  has_many :average_student_sub_grades
end
