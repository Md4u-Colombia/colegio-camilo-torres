class AverageStudentSubGradesController < ApplicationController
  before_action :set_average_student_sub_grade, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @average_student_sub_grades = AverageStudentSubGrade.where("id = 0")
    @educational_periods = EducationalPeriod.order('internal_order')
    @school_year_current = Time.now.year
    # @school_year_current = 2018
    @school_year = SchoolYear.where("name = '?'", @school_year_current).first
    @sub_grades_year_current = SubGradeTeacher.where("school_year_id = ?", get_current_school_year(@school_year_current)).pluck(:sub_grade_id)
    @sub_grades = SubGrade.where("id IN (?)", @sub_grades_year_current).order(:id)

    if params[:commit] == 'filter' or params[:commit] == 'filter_recalculate'
      @sub_grade_id = params[:sub_grade_id]
      @educational_period_id = params[:educational_period_id]

      users = User.where(status: 1)

      @student_sub_grades = StudentSubGrade.where("school_year_id = ? and sub_grade_id = ? and student_id IN (?)", @school_year.id, params[:sub_grade_id], users.pluck(:id)).order(:sub_grade_id)
      if params[:commit] == 'filter_recalculate'
        flag_change_rank = true
        set_position_student_sub_grade(@student_sub_grades, @educational_period_id, flag_change_rank)
      end
      @average_student_sub_grades = AverageStudentSubGrade.where("student_sub_grade_id IN (?) AND educational_period_id = ?", @student_sub_grades.pluck(:id), @educational_period_id).order(:place)
    end
    respond_with(@average_student_sub_grades)
  end

  def set_position_student_sub_grade(student_sub_grades, educational_period_id, flag_change_rank)
    # Llenará la table de average_student_sub_grade quien determinará el puesto del estudiante en el curso
    Rails.logger.info "*********ingresa a set_position_student_sub_grade controller"
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

          @average_student_sub_grade.average = sprintf("%.2f", student_progresses_average.to_f)
          @average_student_sub_grade.save
      end

      @average_student_sub_grades = AverageStudentSubGrade.where("student_sub_grade_id IN (?) AND educational_period_id = ?", student_sub_grades.pluck(:id), educational_period_id).order("average desc, id asc")

      @average_student_sub_grades.each_with_index do |average_student_sub_grade, index|
        average_student_sub_grade.update_attribute(:place, index + 1)
      end
    end
  end

  def show
    respond_with(@average_student_sub_grade)
  end

  def new
    @average_student_sub_grade = AverageStudentSubGrade.new
    respond_with(@average_student_sub_grade)
  end

  def edit
  end

  def create
    @average_student_sub_grade = AverageStudentSubGrade.new(average_student_sub_grade_params)
    @average_student_sub_grade.save
    respond_with(@average_student_sub_grade)
  end

  def update
    @average_student_sub_grade.update(average_student_sub_grade_params)
    respond_with(@average_student_sub_grade)
  end

  def destroy
    @average_student_sub_grade.destroy
    respond_with(@average_student_sub_grade)
  end

  private
    def set_average_student_sub_grade
      @average_student_sub_grade = AverageStudentSubGrade.find(params[:id])
    end

    def average_student_sub_grade_params
      params.require(:average_student_sub_grade).permit(:student_sub_grade_id, :educational_period_id, :average, :average)
    end
end
