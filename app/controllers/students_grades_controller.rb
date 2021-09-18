class StudentsGradesController < ApplicationController
  before_action :set_students_grade, only: [:destroy]
  load_and_authorize_resource :except => [:create]

  respond_to :html

  def index
    @students_grades = StudentsGrade.order("grade_id, school_year_id DESC")
    respond_with(@students_grades)
  end

  def show
    respond_with(@students_grade)
  end

  def new
    @search = StudentsGrade.order("grade_id").search(params[:q])
    @students_grades = @search.result.page(params[:page]).per(30)

    @update_students = StudentsGrade.where("school_year_id=0")

    @students_grade = StudentsGrade.new
    respond_with(@students_grade)
  end

  def update_students
    @update_students = User.where("role_id = 3 AND id NOT IN (SELECT student_id FROM students_grades WHERE school_year_id = #{params[:stid]})").order("last_name")
    respond_to do |format|
      format.js
    end
  end

  def update_student_list
    update_student_list = User.where("role_id = 3 AND id NOT IN (SELECT student_id FROM students_grades WHERE school_year_id = #{params[:stid]})").order("last_name")
    render :partial => "update_student_list", :locals => { :update_student_list => update_student_list }
  end

  def student_sub_grade
    @student_sub_grade = StudentSubGrade.new
    render :layout => false
  end

  def edit
    @update_students = StudentsGrade.where("school_year_id=0")
    @search = StudentsGrade.order("grade_id").search(params[:q])
    @students_grades = @search.result.page(params[:page]).per(30)
  end

  def create
    @update_students = StudentsGrade.where("school_year_id=0")
    @search = StudentsGrade.order("grade_id").search(params[:q])
    @students_grades = @search.result.page(params[:page]).per(30)
    @update_student_list = User.where("role_id = 3 AND id NOT IN (SELECT student_id FROM students_grades WHERE school_year_id = #{params[:students_grade][:school_year_id]})").order("last_name")
    students_size = params[:chk][:student].size
    for i in 0...students_size
      if(StudentsGrade.where("student_id=? AND grade_id=? AND school_year_id=?",params[:chk][:student][i],params[:students_grade][:grade_id],params[:students_grade][:school_year_id]).blank?)
        @students_grade = StudentsGrade.new(students_grade_params)
        @students_grade.student_id = params[:chk][:student][i]
        @students_grade.status = 1
        @students_grade.save
      end
    end
    respond_with(@students_grade, :location => new_students_grade_url)
  end

  def update
    #@update_students = StudentsGrade.where("school_year_id=0")
    #@search = StudentsGrade.order("grade_id").search(params[:q])
    #@students_grades = @search.result.page(params[:page]).per(30)
    #@students_grade.update(students_grade_params)
    respond_with(@students_grade, :location => new_students_grade_url)
  end

  def destroy
    @students_grade.destroy
    respond_with(@students_grade, :location => new_students_grade_url)
  end

  private
    def set_students_grade
      @students_grade = StudentsGrade.find(params[:id])
    end

    def students_grade_params
      params.require(:students_grade).permit(:student_id, :grade_id, :school_year_id, :status)
    end
end
