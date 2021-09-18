class SubGrade < ActiveRecord::Base
	has_many :teacher_asignatures
	has_many :student_sub_grades
	has_many :educational_performances
	belongs_to :grade
	belongs_to :course_director, :class_name => "User", :foreign_key => "course_director_id"

  validates :grade_id,:course_director_id, :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }
end
