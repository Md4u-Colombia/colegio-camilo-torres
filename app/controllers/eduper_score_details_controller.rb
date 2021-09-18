class EduperScoreDetailsController < ApplicationController
  load_and_authorize_resource :except => [:new, :create, :edit, :update, :destroy]
  before_action :set_eduper_score_detail, only: [:edit, :show, :destroy]

  helper_method :automatic_calculation_weight, :update_scores_in_table_student_tracking

  respond_to :html

  def index
    @eduper_score_details = EduperScoreDetail.all
    respond_with(@eduper_score_details)
  end

  def show
    respond_with(@eduper_score_detail)
  end

  def new
    limit_activity = 6
    @eduper_score_detail = EduperScoreDetail.new
    @sub_grade = SubGrade.find(params[:sgid])

    # OBTENER GRADE_ASIGNATURE_ID
    grade_asignature_id = GradeAsignature.where("grade_id = ? AND educational_asignature_id = ? AND school_year_id = ?", @sub_grade.grade_id, params[:eaid], params[:syid]).first.id

    @educational_performance_grades =EducationalPerformanceGrade.where("educational_period_id = ? AND grade_asignature_id = ? AND educational_performances_list_id <> 1", params[:epid], grade_asignature_id)

    @sd_details = SdDetail.where("id <> 2").order(:name) # Debe ser diferente de 2 ya que 2 es el detalle de evaluación final
    @sub_grade_teacher = SubGradeTeacher.where("sub_grade_id = ? AND school_year_id = ? AND teacher_id = ?", params[:sgid], params[:syid], current_user.id).first.id

    # Verificar la cantidad máxima es de 6 actividades y que no sobrepase el 100% del peso por desempeño
    performance_ids = Array.new
    index = 0
    @educational_performance_grades.each do |performance|
      @eduper_score_details = EduperScoreDetail.where("educational_performance_grade_id = ? AND sub_grade_teacher_id = ?", performance.id, @sub_grade_teacher) # Debe ser el educational_performances_list_id diferente de uno ya que 1 es la evaluacion final
      if @eduper_score_details.size == limit_activity
        puts "**********ES menor o igual a 6: #{@eduper_score_details.size}"
        @educational_performance_grades = @educational_performance_grades.where("id <> ?", performance.id)
      end
    end

    render :layout => false
    #respond_with(@eduper_score_detail)
  end

  def update_percentage_performance
    # @eduper_score_details = EduperScoreDetail.where("")
    respond_to do |format|
      format.js { return 100 }
    end
  end

  def edit
    limit_activity = 6
    @sub_grade = SubGrade.find(params[:sgid])
    # OBTENER GRADE_ASIGNATURE_ID
    grade_asignature_id = GradeAsignature.where("grade_id = ? AND educational_asignature_id = ? AND school_year_id = ?", @sub_grade.grade_id, params[:eaid], params[:syid]).first.id

    @educational_performance_grades =EducationalPerformanceGrade.where("educational_period_id = ? AND grade_asignature_id = ? AND educational_performances_list_id <> 1", params[:epid], grade_asignature_id)

    @sd_details = SdDetail.order(:name)
    @sub_grade_teacher = SubGradeTeacher.where("sub_grade_id = ? AND school_year_id = ? AND teacher_id = ?", params[:sgid], params[:syid], current_user.id).first.id
    render :layout => false
  end

  def update_asignatures
    # if current_user.role_id == 0 or current_user.role_id == 1
    #   @sub_grade_teachers = SubGradeTeacher.where("sub_grade_id = ? AND school_year_id = ?", params[:sg_id], params[:syid])
    #   @teacher_asignatures = TeacherAsignature.where("sub_grade_teacher_id IN (?)", @sub_grade_teachers.pluck(:id)).pluck(:educational_asignature_id)
    #   @educational_asignatures = EducationalAsignature.where("id IN (?)", @teacher_asignatures).order(:name)#.map { |e| [e.id, e.name] }
    # else
      @sub_grade_teacher = SubGradeTeacher.where("sub_grade_id = ? and teacher_id = ? AND school_year_id = ?", params[:sg_id], current_user, params[:syid])
      @teacher_asignatures = TeacherAsignature.where("sub_grade_teacher_id = ?", @sub_grade_teacher.first.id).pluck(:educational_asignature_id)
      @educational_asignatures = EducationalAsignature.where("id IN (?)", @teacher_asignatures).order(:name)#.map { |e| [e.id, e.name] }
    # end

    respond_to do |format|
      format.js
    end
  end

  def automatic_calculation_weight(epgid, sgtid)
    @eduper_score_details_tmp = EduperScoreDetail.where("educational_performance_grade_id = ? AND sub_grade_teacher_id = ?", epgid, sgtid)
    if @eduper_score_details_tmp.any?
      weight = 100.0 / (@eduper_score_details_tmp.size + 1)
      @eduper_score_details_tmp.each do |eduper_score_detail|
        # ACTUAILIZAMOS TODOS LOS PESOS QUE CORRESPONDAN AL MISMO DESEMPEÑO
        eduper_score_detail.weight = weight
        eduper_score_detail.save
      end
    else
      weight = 100.0
    end

    return weight
  end

  def update_scores_in_table_student_tracking(eaid, sgid, syid, epid)
    sub_grade_teacher_id = get_sub_grade_teacher(sgid, syid, current_user.id)
    educational_performance_grades = EducationalPerformanceGrade.where("id IN (?)", get_educational_performance_grades(get_grade_asignature(sgid, syid, eaid), epid))
    eduper_score_details = EduperScoreDetail.where("educational_performance_grade_id IN (?) AND sd_detail_id <> 2 AND sub_grade_teacher_id = ?", get_educational_performance_grades(get_grade_asignature(sgid, syid, eaid), epid), sub_grade_teacher_id)
    student_trackings = StudentTracking.where("eduper_score_detail_id IN (?)", eduper_score_details.pluck(:id))

    student_trackings.each do |student_tracking|
      compliance = student_tracking.score.to_f * student_tracking.eduper_score_detail.weight.to_f / 100.0
      if student_tracking.eduper_score_detail.sd_detail_id != 2
        compliance *= (0.75 / educational_performance_grades.where("educational_performances_list_id <> 1").size.to_f)
      end

      student_tracking.compliance = compliance
      student_tracking.save
    end
  end

  def create
    # SI LA OPCION ES EVALUACIÓN FINAL
    # if params[:eduper_score_detail][:sd_detail_id].to_i == 2
    #   params[:eduper_score_detail][:weight] = 25
    #   puts
    # end

    # CALCULO AUTOMÁTICO DEL PESO
    epgid = params[:eduper_score_detail][:educational_performance_grade_id]
    sgtid = params[:eduper_score_detail][:sub_grade_teacher_id]
    eaid = params[:eaid]
    sgid = params[:sgid]
    syid = params[:syid]
    epid = params[:epid]
    params[:eduper_score_detail][:weight] = automatic_calculation_weight(epgid, sgtid)

    @eduper_score_detail = EduperScoreDetail.new(eduper_score_detail_params)
    sub_grade_teacher_id = SubGradeTeacher.where("sub_grade_id = ? AND teacher_id = ? AND school_year_id = ?")

    if @eduper_score_detail.save
      update_scores_in_table_student_tracking(eaid, sgid, syid, epid) # Después de actualizar los pesos actualiza los cumplimientos de las notas ingresadas con éstos nuevos pesos
      respond_with(@eduper_score_detail, location: edit_eduper_score_detail_url(@eduper_score_detail.id, eaid: params[:eaid], epid: params[:epid], sgid: params[:sgid], syid: params[:syid]))
    else
      @sub_grade = SubGrade.find(params[:sgid])

      # OBTENER GRADE_ASIGNATURE_ID
      grade_asignature_id = GradeAsignature.where("grade_id = ? AND educational_asignature_id = ? AND school_year_id = ?", @sub_grade.grade_id, params[:eaid], params[:syid]).first.id

      @educational_performance_grades =EducationalPerformanceGrade.where("educational_period_id = ? AND grade_asignature_id = ?", params[:epid], grade_asignature_id)

      @sd_details = SdDetail.order(:name)
      @sub_grade_teacher = SubGradeTeacher.where("sub_grade_id = ? AND school_year_id = ? AND teacher_id = ?", params[:sgid], params[:syid], current_user.id).first.id
      respond_with(@eduper_score_detail)
    end
  end

  def update
    @eduper_score_detail.update(eduper_score_detail_params)
    respond_with(@eduper_score_detail)
  end

  def destroy
    @eduper_score_detail.destroy
    respond_with(@eduper_score_detail)
  end

  private
    def set_eduper_score_detail
      @eduper_score_detail = EduperScoreDetail.find(params[:id])
    end

    def eduper_score_detail_params
      params.require(:eduper_score_detail).permit(:name, :description, :educational_performance_grade_id, :sd_detail_id, :sub_grade_teacher_id, :weight)
    end
end
