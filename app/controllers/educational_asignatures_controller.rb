class EducationalAsignaturesController < ApplicationController
  load_and_authorize_resource :except => [:create,:destroy]
  before_action :set_educational_asignature, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @search = EducationalAsignature.search(params[:q])
    @educational_asignatures = @search.result.page(params[:page]).per(20)
    respond_with(@educational_asignatures)
  end

  def show
    respond_with(@educational_asignature)
  end

  def new
    @educational_asignature = EducationalAsignature.new
    @search = EducationalAsignature.search(params[:q])
    @educational_asignatures = @search.result.includes(:educational_area).page(params[:page]).per(20)
    respond_with(@educational_asignature)
  end

  def edit
    @search = EducationalAsignature.search(params[:q])
    @educational_asignatures = @search.result.page(params[:page]).per(20)
  end

  def create
    @educational_asignature = EducationalAsignature.new(educational_asignature_params)

    str_errors=0
    str_msg = ""
    if(EducationalAsignature.where("educational_area_id=? AND name LIKE '#{params[:educational_asignature][:name]}'",params[:educational_asignature][:educational_area_id]).any?)
      str_msg += '<i class="fa fa-hand-o-right"></i>&nbsp;Ya se encuentra creada la asignación que esta realizando.<br>'
      str_errors +=1  
    end
    if(str_errors.to_i > 0)
      flash[:error] = str_msg.to_s
      redirect_to url_for(:action => :new)
    else
      unless @educational_asignature.save
        @search = EducationalAsignature.search(params[:q])
        @educational_asignatures = @search.result.page(params[:page]).per(20)
      end
      respond_with(@educational_asignature, location: new_educational_asignature_url)
    end
  end

  def update
    str_errors=0
    str_msg = ""
    if(EducationalAsignature.where("educational_area_id=? AND name LIKE '#{params[:educational_asignature][:name]}'",params[:educational_asignature][:educational_area_id]).any?)
      str_msg += '<i class="fa fa-hand-o-right"></i>&nbsp;Ya se encuentra creada la asignación que esta realizando.<br>'
      str_errors +=1  
    end
    if(str_errors.to_i > 0)
      flash[:error] = str_msg.to_s
      redirect_to url_for(:action => :new)
    else
      unless @educational_asignature.update(educational_asignature_params)
        @search = EducationalAsignature.search(params[:q])
        @educational_asignatures = @search.result.page(params[:page]).per(20)
      end
      respond_with(@educational_asignature, location: new_educational_asignature_url)
    end
  end

  def destroy
    @educational_asignature.destroy
    respond_with(@educational_asignature, location: new_educational_asignature_url)
  end

  private
    def set_educational_asignature
      @educational_asignature = EducationalAsignature.find(params[:id])
    end

    def educational_asignature_params
      params.require(:educational_asignature).permit(:educational_area_id, :name, :description)
    end
end
