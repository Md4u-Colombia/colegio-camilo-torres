class StudentProgress < ActiveRecord::Base
  attr_accessor :student_sub_grades, :educational_period_id, :flag_change_rank

	belongs_to :educational_asignature
	belongs_to :grade_asignature
	belongs_to :period
	belongs_to :student_sub_grade
	belongs_to :educational_performance
	belongs_to :period, :class_name => "EducationalPeriod", :foreign_key => "period_id"

  after_save :set_position_student_sub_grade

  def set_position_student_sub_grade
    Rails.logger.info "*********ingresa a set_position_student_sub_grade model"
    puts "flag_change_rank: #{flag_change_rank}"
    if flag_change_rank
      student_sub_grades.each do |student_sub_grade|
        student_progresses_average = StudentProgress.where("student_sub_grade_id = ? AND period_id = ?", student_sub_grade.id, educational_period_id).average(:score)
          if AverageStudentSubGrade.where("student_sub_grade_id = ? AND educational_period_id = ?", student_sub_grade.id, educational_period_id).any?
            @average_student_sub_grade = AverageStudentSubGrade.where("student_sub_grade_id = ? AND educational_period_id = ?", student_sub_grade.id, educational_period_id).first
          else
            @average_student_sub_grade = AverageStudentSubGrade.new
            @average_student_sub_grade.student_sub_grade_id = student_sub_grade.id
            @average_student_sub_grade.educational_period_id = educational_period_id
          end

          @average_student_sub_grade.average = student_progresses_average.to_f
          @average_student_sub_grade.save
      end

      @average_student_sub_grades = AverageStudentSubGrade.where("student_sub_grade_id IN (?) AND educational_period_id = ?", student_sub_grades.pluck(:id), educational_period_id).order("average desc, id asc")

      @average_student_sub_grades.each_with_index do |average_student_sub_grade, index|
        average_student_sub_grade.update_attribute(:place, index + 1)
      end
    end
  end
end
