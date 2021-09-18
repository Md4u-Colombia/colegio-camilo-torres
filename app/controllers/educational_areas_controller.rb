class EducationalAreasController < ApplicationController
  load_and_authorize_resource :except => [:create,:destroy]

  before_action :set_educational_area, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @search = @EducationalArea.search(params[:q])
    @educational_areas = @search.result
    respond_with(@educational_areas)
  end

  def show
    respond_with(@educational_area)
  end

  def new
    @educational_area = EducationalArea.new
    @search = EducationalArea.order('name').search(params[:q])
    @educational_areas = @search.result.page(params[:page]).per(20)
    respond_with(@educational_area)
  end

  def edit
    @search = EducationalArea.search(params[:q])
    @educational_areas = @search.result.page(params[:page]).per(20)
  end

  def create
    @educational_area = EducationalArea.new(educational_area_params)
    unless @educational_area.save
      @search = EducationalArea.search(params[:q])
      @educational_areas = @search.result.page(params[:page]).per(20)
    end
    respond_with(@educational_area, location: new_educational_area_url)
  end

  def update
    unless @educational_area.update(educational_area_params)
      @search = EducationalArea.search(params[:q])
      @educational_areas = @search.result.page(params[:page]).per(20)
    end
    respond_with(@educational_area, location: new_educational_area_url)
  end

  def destroy
    @educational_area.destroy
    respond_with(@educational_area, location: new_educational_area_url)
  end

  private
    def set_educational_area
      @educational_area = EducationalArea.find(params[:id])
    end

    def educational_area_params
      params.require(:educational_area).permit(:education_level_id, :name, :description)
    end
end
