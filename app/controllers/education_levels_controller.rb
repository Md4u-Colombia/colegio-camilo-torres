class EducationLevelsController < ApplicationController
  load_and_authorize_resource :except => [:create,:destroy]

  before_action :set_education_level, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @education_levels = EducationLevel.all
    respond_with(@education_levels)
  end

  def show
    respond_with(@education_level)
  end

  def new
    @education_level = EducationLevel.new
    @education_levels = EducationLevel.all
    respond_with(@education_level)
  end

  def edit
    @education_levels = EducationLevel.all
  end

  def create
    @education_level = EducationLevel.new(education_level_params)
    unless @education_level.save
      @education_levels = EducationLevel.all
    end
    respond_with(@education_level, location: new_education_level_url)
  end

  def update
    unless @education_level.update(education_level_params)
      @education_levels = EducationLevel.all
    end
    respond_with(@education_level, location: new_education_level_url)
  end

  def destroy
    @education_level.destroy
    respond_with(@education_level, location: new_education_level_url)
  end

  private
    def set_education_level
      @education_level = EducationLevel.find(params[:id])
    end

    def education_level_params
      params.require(:education_level).permit(:name, :description)
    end
end
