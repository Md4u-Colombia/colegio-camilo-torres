class AverageStudentSubGrade < ActiveRecord::Base
  belongs_to :student_sub_grade
  belongs_to :educational_period
end
