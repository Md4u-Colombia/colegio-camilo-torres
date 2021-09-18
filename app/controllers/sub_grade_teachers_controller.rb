class SubGradeTeachersController < ApplicationController
  load_and_authorize_resource :except => [:create,:destroy]
  before_action :set_sub_grade_teacher, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @search = SubGradeTeacher.order("teacher_id,sub_grade_id").search(params[:q])
    @sub_grade_teachers = @search.result.page(params[:page]).per(20)
    respond_with(@sub_grade_teachers)
  end

  def show
    respond_with(@sub_grade_teacher)
  end

  def new
    @sub_grade_teacher = SubGradeTeacher.new
    @search = SubGradeTeacher.order("teacher_id,sub_grade_id").search(params[:q])
    @sub_grade_teachers = @search.result.page(params[:page]).per(20)
    respond_with(@sub_grade_teacher)
  end

  def edit
  end

  def create
    @search = SubGradeTeacher.order("teacher_id,sub_grade_id").search(params[:q])
    @sub_grade_teachers = @search.result.page(params[:page]).per(20)
    date_now = Time.now
    year_now = date_now.strftime("%Y")
    school_year = SchoolYear.where("date_begin LIKE '%#{year_now}%'")
    chk_sub_grade = params[:chk][:sub_grade]
    for s in 0...chk_sub_grade.size
      @find_sub_grade_teachers = SubGradeTeacher.where("teacher_id = ? AND sub_grade_id = ? AND school_year_id = ?", sub_grade_teacher_params[:teacher_id], chk_sub_grade[s], get_current_school_year(Time.now.year))
      unless(@find_sub_grade_teachers.any?)
        @sub_grade_teacher = SubGradeTeacher.new()
        @sub_grade_teacher.teacher_id = sub_grade_teacher_params[:teacher_id]
        @sub_grade_teacher.sub_grade_id = chk_sub_grade[s]
        @sub_grade_teacher.school_year_id = school_year.first.id
        @sub_grade_teacher.save
      end
    end
    respond_with(@sub_grade_teacher, location: new_sub_grade_teacher_url)
  end

  def update
    @sub_grade_teacher.update(sub_grade_teacher_params)
    @search = SubGradeTeacher.order("teacher_id,sub_grade_id").search(params[:q])
    @sub_grade_teachers = @search.result.page(params[:page]).per(20)
    respond_with(@sub_grade_teacher)
  end

  def destroy
    @sub_grade_teacher.destroy
    @search = SubGradeTeacher.order("teacher_id,sub_grade_id").search(params[:q])
    @sub_grade_teachers = @search.result.page(params[:page]).per(20)
    respond_with(@sub_grade_teacher, location: new_sub_grade_teacher_url)
  end

  private
    def set_sub_grade_teacher
      @sub_grade_teacher = SubGradeTeacher.find(params[:id])
    end

    def sub_grade_teacher_params
      params.require(:sub_grade_teacher).permit(:teacher_id, :sub_grade_id)
    end
end
