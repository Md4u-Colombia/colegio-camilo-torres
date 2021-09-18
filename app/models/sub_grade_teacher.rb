class SubGradeTeacher < ActiveRecord::Base
	validates :teacher_id, presence: true
	validates :sub_grade_id, presence: true
	belongs_to :sub_grade
	belongs_to :teacher, :class_name => "User", :foreign_key => "teacher_id"
	belongs_to :school_year
	has_many :teacher_asignature
end
