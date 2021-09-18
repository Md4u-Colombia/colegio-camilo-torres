class GradeAsignaturesController < ApplicationController
  before_action :set_grade_asignature, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def duplicate_grade_asignatures
    res = 0

    grade_asignatures_old = GradeAsignature.where("school_year_id = ?", params[:school_year_id_old])
    grade_asignatures_current = GradeAsignature.where("school_year_id = ?", params[:school_year_id_current])

    if grade_asignatures_old.any?
      grade_asignatures_old.each do |grade_asignature_old|
        if grade_asignatures_current.size <= grade_asignatures_old.size
          grade_asignature = GradeAsignature.new
          grade_asignature.educational_asignature_id = grade_asignature_old.educational_asignature_id
          grade_asignature.grade_id = grade_asignature_old.grade_id
          grade_asignature.internal_order = grade_asignature_old.internal_order
          grade_asignature.status = grade_asignature_old.status
          grade_asignature.school_year_id = params[:school_year_id_current]
          if grade_asignature.save
            res = 1
          else
            res = 3
          end
        end
      end
    else
      res = 0
    end
    respond_to do |format|
      format.json { render json: res }
     end
  end

  def index
    @grade_asignatures = GradeAsignature.order("grade_id,internal_order")
    @search = @grade_asignatures.search(params[:q])
    @grade_asignatures = @search.result.page(params[:page]).per(30)
    respond_with(@grade_asignatures)
  end

  def show
    respond_with(@grade_asignature)
  end

  def new
    @grade_asignature = GradeAsignature.new
    @grade_asignatures = GradeAsignature.order("grade_id,internal_order")
    @search = @grade_asignatures.search(params[:q])
    @grade_asignatures = @search.result.page(params[:page]).per(30)
    respond_with(@grade_asignature)
  end

  def edit
    @grade_asignatures = GradeAsignature.order("grade_id,internal_order")
    @search = @grade_asignatures.search(params[:q])
    @grade_asignatures = @search.result.page(params[:page]).per(30)
  end

  def create
    @grade_asignatures = GradeAsignature.order("grade_id,internal_order")
    @search = @grade_asignatures.search(params[:q])
    @grade_asignatures = @search.result.page(params[:page]).per(30)
    @grade_asignature = GradeAsignature.new(grade_asignature_params)
    @grade_asignature.save
    respond_with(@grade_asignature, location: new_grade_asignature_url)
  end

  def update
    @grade_asignatures = GradeAsignature.order("grade_id,internal_order")
    @search = @grade_asignatures.search(params[:q])
    @grade_asignatures = @search.result.page(params[:page]).per(30)
    @grade_asignature.update(grade_asignature_params)
    respond_with(@grade_asignature, location: new_grade_asignature_url)
  end

  def destroy
    @grade_asignatures = GradeAsignature.order("grade_id,internal_order")
    @search = @grade_asignatures.search(params[:q])
    @grade_asignatures = @search.result.page(params[:page]).per(30)
    @grade_asignature.destroy
    respond_with(@grade_asignature, location: new_grade_asignature_url)
  end

  private
    def set_grade_asignature
      @grade_asignature = GradeAsignature.find(params[:id])
    end

    def grade_asignature_params
      params.require(:grade_asignature).permit(:educational_asignature_id, :grade_id, :internal_order, :school_year_id)
    end
end
