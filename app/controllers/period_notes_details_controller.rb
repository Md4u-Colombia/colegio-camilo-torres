class PeriodNotesDetailsController < ApplicationController
  load_and_authorize_resource :except => [:create,:period_notes_details]
  before_action :set_period_notes_detail, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @period_notes_details = PeriodNotesDetail.order("teacher_id,educational_performance_id")
    if(current_user.role_id == 2)
      @period_notes_details = @period_notes_details.where("teacher_id=?",current_user.id)
    end
    respond_with(@period_notes_details)
  end

  def show
    respond_with(@period_notes_detail)
  end
  
  def new
    @period_notes_detail = PeriodNotesDetail.new
    respond_with(@period_notes_detail)
  end

  def edit
  end

  def create
    @period_notes_detail = PeriodNotesDetail.new(period_notes_detail_params)
    str_errors=0
    str_msg = ""
    if(params[:period_notes_detail][:school_year_id] == "")
      str_msg += '* Año escolar es requerido.<br>'
      str_errors +=1
    end
    if(params[:period_notes_detail][:educational_period_id] == "")
      str_msg += '* Periodo es requerido.<br>'
      str_errors +=1
    end
    if(params[:period_notes_detail][:period_weight] == "")
      str_msg += '* Peso de Periodo es requerido.<br>'
      str_errors +=1
    end
    if(params[:period_notes_detail][:teacher_asignature_id] == "")
      str_msg += '* Curso es requerido.<br>'
      str_errors +=1
    end
    if(params[:period_notes_detail][:educational_performance_id] == "")
      str_msg += '* Desempeño es requerido.<br>'
      str_errors +=1
    end
    if(params[:period_notes_detail][:performance_weight] == "")
      str_msg += '* Peso Desempeño es requerido.<br>'
      str_errors +=1
    end
    if(params[:period_notes_detail][:sd_detail_id] == "")
      str_msg += '* Detalle es requerido.<br>'
      str_errors +=1
    end
    if(params[:period_notes_detail][:detail_weight] == "")
      str_msg += '* Peso Detalle es requerido.<br>'
      str_errors +=1
    end
    if(str_errors.to_i > 0)
      flash[:error] = str_msg.to_s
      unless(params[:period_notes_detail][:teacher_asignature_id] == "")
        puts "teacher_asignature_id => #{params[:period_notes_detail][:teacher_asignature_id]}"
        @period_notes_details = EducationalPerformance.where("educational_asignature_id IN (?)",TeacherAsignature.find(params[:period_notes_detail][:teacher_asignature_id]).educational_asignature_id)
      end
      redirect_to url_for(:controller => :period_notes_details, :action => :new)
    else
      @period_notes_detail.save
      respond_with(@period_notes_detail, :location => period_notes_details_path)
    end
    #if(@period_notes_detail.save)
      #respond_with(@period_notes_detail, :location => period_notes_details_path)
    #else
      #respond_with(@period_notes_detail, :location => new_period_notes_detail_path)
    #end
  end

  def update
    str_errors=0
    str_msg = ""
    if(params[:period_notes_detail][:school_year_id] == "")
      str_msg += '* Año escolar es requerido.<br>'
      str_errors +=1
    end
    if(params[:period_notes_detail][:educational_period_id] == "")
      str_msg += '* Periodo es requerido.<br>'
      str_errors +=1
    end
    if(params[:period_notes_detail][:period_weight] == "")
      str_msg += '* Peso de Periodo es requerido.<br>'
      str_errors +=1
    end
    if(params[:period_notes_detail][:teacher_asignature_id] == "")
      str_msg += '* Curso es requerido.<br>'
      str_errors +=1
    end
    if(params[:period_notes_detail][:educational_performance_id] == "")
      str_msg += '* Desempeño es requerido.<br>'
      str_errors +=1
    end
    if(params[:period_notes_detail][:performance_weight] == "")
      str_msg += '* Peso Desempeño es requerido.<br>'
      str_errors +=1
    end
    if(params[:period_notes_detail][:sd_detail_id] == "")
      str_msg += '* Detalle es requerido.<br>'
      str_errors +=1
    end
    if(params[:period_notes_detail][:detail_weight] == "")
      str_msg += '* Peso Detalle es requerido.<br>'
      str_errors +=1
    end
    if(str_errors.to_i > 0)
      flash[:error] = str_msg.to_s
      redirect_to url_for(:controller => :period_notes_details, :action => :edit)
    else
      @period_notes_details= EducationalPerformance.where("educational_asignature_id IN (?)",TeacherAsignature.find(set_period_notes_detail.teacher_asignature_id)).order("description")
      @period_notes_detail.update(period_notes_detail_params)
      respond_with(@period_notes_detail, :location => period_notes_details_path)
    end
  end

  def destroy
    @period_notes_detail.destroy
    respond_with(@period_notes_detail)
  end

  def period_notes_details
    @period_notes_details = EducationalPerformance.where("educational_asignature_id IN (?)",TeacherAsignature.find(params[:pndt_asignature_id]).educational_asignature_id)
    respond_to do |format|
      format.js
    end
  end

  private
    def set_period_notes_detail
      @period_notes_detail = PeriodNotesDetail.find(params[:id])
    end

    def period_notes_detail_params
      params.require(:period_notes_detail).permit(:school_year_id, :teacher_asignature_id, :educational_performance_id, :performance_weight, :sd_detail_id, :detail_weight, :educational_period_id, :period_weight, :teacher_id)
    end
end
