class EducationalPerformanceGrade < ActiveRecord::Base
  belongs_to :educational_performances_list
  belongs_to :grade_asignature
  belongs_to :educational_period
end
