class SubGradesController < ApplicationController
  load_and_authorize_resource :except => [:create]
  before_action :set_sub_grade, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @search = SubGrade.order("grade_id")
    if(current_user.role_id == 2)
      @search = @search.where("course_director_id=?",current_user.id).search(params[:q])
      @sub_grades = @search.result.page(params[:page]).per(20)
    else
      @search = @search.search(params[:q])
      @sub_grades = @search.result.page(params[:page]).per(20)
    end
    respond_with(@sub_grades)
  end

  def show
    respond_with(@sub_grade)
  end

  def new
    @sub_grade = SubGrade.new
    @search = SubGrade.order("grade_id").search(params[:q])
    @sub_grades = @search.result.page(params[:page]).per(20)
    respond_with(@sub_grade)
  end

  def edit
    @search = SubGrade.order("grade_id").search(params[:q])
    @sub_grades = @search.result.page(params[:page]).per(20)
  end

  def create
    @sub_grade = SubGrade.new(sub_grade_params)
    unless @sub_grade.save
      @search = SubGrade.order("grade_id").search(params[:q])
      @sub_grades = @search.result.page(params[:page]).per(20)
    end
    respond_with(@sub_grade, location: new_sub_grade_url)
  end

  def update
    unless @sub_grade.update(sub_grade_params)
      @search = SubGrade.order("grade_id").search(params[:q])
      @sub_grades = @search.result.page(params[:page]).per(20)
    end
    respond_with(@sub_grade, location: new_sub_grade_url)
  end

  def destroy
    @sub_grade.destroy
    respond_with(@sub_grade, location: new_sub_grade_url)
  end

  private
    def set_sub_grade
      @sub_grade = SubGrade.find(params[:id])
    end

    def sub_grade_params
      params.require(:sub_grade).permit(:grade_id, :course_director_id, :name, :description)
    end
end
