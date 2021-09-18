class StudentsGrade < ActiveRecord::Base
	validates :school_year_id,:grade_id, presence: true
	validate :perform_validation_of_field
	
	def perform_validation_of_field
	   if self.student_id == 1
	     	errors.add(:base, "Debe seleccionar por lo menos un alumno.")      
	   end
	end
	
  	belongs_to :grade
  	belongs_to :school_year
  	belongs_to :student, :class_name => "User", :foreign_key => "student_id"
  	has_many :student_sub_grade
end
