class GradesController < ApplicationController
  load_and_authorize_resource :except => [:create,:destroy]

  before_action :set_grade, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @search = Grade.search(params[:q])
    @grades = @search.result.page(params[:page]).per(20)
    respond_with(@grades)
  end

  def show
    respond_with(@grade)
  end

  def new
    @grade = Grade.new
    @search = Grade.search(params[:q])
    @grades = @search.result.page(params[:page]).per(20)
    respond_with(@grade)
  end

  def edit
    @search = Grade.search(params[:q])
    @grades = @search.result.page(params[:page]).per(20)
  end

  def create
    @grade = Grade.new(grade_params)
    unless @grade.save
      @search = Grade.search(params[:q])
      @grades = @search.result.page(params[:page]).per(20)
    end
    respond_with(@grade, location: new_grade_url)
  end

  def update
    unless @grade.update(grade_params)
      @search = Grade.search(params[:q])
      @grades = @search.result.page(params[:page]).per(20)
    end
    respond_with(@grade, location: new_grade_url)
  end

  def destroy
    @grade.destroy
    respond_with(@grade, location: new_grade_url)
  end

  private
    def set_grade
      @grade = Grade.find(params[:id])
    end

    def grade_params
      params.require(:grade).permit(:education_level_id, :name, :description)
    end
end
