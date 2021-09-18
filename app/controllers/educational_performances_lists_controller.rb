class EducationalPerformancesListsController < ApplicationController
  load_and_authorize_resource :except => [:create, :update_educational_asignature]
  before_action :set_educational_performances_list, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @grades = Grade.order(:id)
    @search = EducationalPerformancesList.includes(:grades, :eduational_asignatures).search(params[:q])
    @educational_performances_lists = @search.where("educational_performances_lists.grade_asignature_id IS NOT NULL").result
    respond_with(@educational_areas)
  end

  def educational_asignatures
    educational_asignature = GradeAsignatures.where(params[:grade_id])
    respond_to do |format|
    format.json { render :json => educational_asignature.educational_asignature }
    end
  end

  def update_educational_asignature
    @update_educational_asignature = GradeAsignature.where("grade_id = ?", params[:gid])
    respond_to do |format|
      format.js
    end
  end

  def show
    respond_with(@educational_performances_list)
  end

  def new
    @grades_select = Grade.order(:id)
    @educational_performances_list = EducationalPerformancesList.new
    @educational_performances_lists_tmp = EducationalPerformancesList.where("grade_id IS NOT NULL")
    @grades = Grade.where("id IN (?)", @educational_performances_lists_tmp.map { |g| g.grade_id }).order(:id)    
    @update_educational_asignature = GradeAsignature.where("grade_id=0")
    @search = EducationalPerformancesList.order(:description).search(params[:q])
    @educational_performances_lists = @search.result.page(params[:page]).per(20)
    respond_with(@educational_performances_list)
  end

  def edit
    @grades_select = Grade.order(:id)
    @educational_performances_lists_tmp = EducationalPerformancesList.where("grade_id IS NOT NULL")
    @grades = Grade.where("id IN (?)", @educational_performances_lists_tmp.map { |g| g.grade_id }).order(:id)
    @update_educational_asignature = GradeAsignature.where("grade_id=0")
    @search = EducationalPerformancesList.search(params[:q])
    @educational_performances_lists = @search.result.page(params[:page]).per(20)
  end

  def create
    if params[:grade_id]
      @grade_id = params[:grade_id]
      @update_educational_asignature = EducationalAsignature.where("id IN (?)", GradeAsignature.where("grade_id = ?", params[:grade_id]).pluck(:educational_asignature_id))
    else
      @update_educational_asignature = GradeAsignature.where("grade_id = 0")
    end
    @educational_asignature_id = params[:educational_asignature_id] if params[:educational_asignature_id]
    @grades_select = Grade.order(:id)
    @grade_asignature = GradeAsignature.where("grade_id = ? and educational_asignature_id = ?", params[:grade_id], params[:educational_asignature_id])

    if @grade_asignature.any?
      params[:educational_performances_list][:grade_asignature_id] = @grade_asignature.first.id
    end

    @educational_performances_list = EducationalPerformancesList.new(educational_performances_list_params)

    @educational_performances_lists_tmp = EducationalPerformancesList.where("grade_id IS NOT NULL")
    @grades = Grade.where("id IN (?)", @educational_performances_lists_tmp.map { |g| g.grade_id }).order(:id)
    

    # validate_fields(params[:grade_id], params[:educational_asignature_id])

    unless @educational_performances_list.save
      @search = EducationalPerformancesList.search(params[:q])
      @educational_performances_lists = @search.result.page(params[:page]).per(20)
    end
    respond_with(@educational_performances_list, location: new_educational_performances_list_url)
  end

  def update
    @grades_select = Grade.order(:id)
    @grade_asignature = GradeAsignature.where("grade_id = ? and educational_asignature_id = ?", params[:grade_id], params[:educational_asignature_id])

    if @grade_asignature.any?
      params[:educational_performances_list][:grade_asignature_id] = @grade_asignature.first.id
    end

    @educational_performances_lists_tmp = EducationalPerformancesList.where("grade_id IS NOT NULL")
    @grades = Grade.where("id IN (?)", @educational_performances_lists_tmp.map { |g| g.grade_id }).order(:id)

    # validate_fields(params[:grade_id], params[:educational_asignature_id])

    unless @educational_performances_list.update(educational_performances_list_params)
      @search = EducationalPerformancesList.search(params[:q])
      @educational_performances_lists = @search.result.page(params[:page]).per(20)
      @update_educational_asignature = GradeAsignature.where("grade_id = 0")
    end
    respond_with(@educational_performances_list, location: new_educational_performances_list_url)
  end

  # def validate_fields(grade_id, educational_asignature_id)
  #   if grade_id.blank?
  #     @educational_performances_list.perform_validation_grade_id = true
  #   else
  #     @educational_performances_list.perform_validation_grade_id = false
  #   end

  #   if educational_asignature_id.blank?
  #     @educational_performances_list.perform_validation_educational_asignature_id = true
  #   else
  #     @educational_performances_list.perform_validation_educational_asignature_id = false
  #   end
  # end

  def destroy
    @educational_performances_list.destroy
    respond_with(@educational_performances_list, location: new_educational_performances_list_url)
  end

  private
    def set_educational_performances_list
      @educational_performances_list = EducationalPerformancesList.find(params[:id])
    end

    def educational_performances_list_params
      params.require(:educational_performances_list).permit(:description, :grade_id, :status, :perform_validation_of_field1)
    end
end
