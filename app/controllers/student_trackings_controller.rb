class StudentTrackingsController < ApplicationController
  load_and_authorize_resource :except => [:create, :destroy, :filter_score]
  before_action :set_student_tracking, only: [:show, :edit, :update, :destroy]
  helper_method :getColorClass, :exist_field_evaluation

  respond_to :html

  def score_tracking_report
    if params[:school_year_id].present?
      @school_year = SchoolYear.find(params[:school_year_id])
      @school_year_current = @school_year.name
    else
      @school_year_current = Time.now.year
      @school_year = SchoolYear.where("name = '?'", @school_year_current).first
    end
    @school_years = SchoolYear.order(:name)
    @educational_asignature_id = params[:score_detail_educational_asignature_id]

    # OBTENER EL PERIODO ACTUAL Y EL SELECT AUTOMÁTICO DEL PERIODO
    educational_period_current = EducationalPeriod.find(get_current_period())
    if params[:educational_period_id].present?
      @educational_period_id = params[:educational_period_id]
      @educational_period_id_range = @educational_period_id
      educational_period = EducationalPeriod.find(@educational_period_id_range)
    else
      @educational_period_id_range = educational_period_current.id
      educational_period = EducationalPeriod.find(@educational_period_id_range)
      @educational_period_id = educational_period.id
    end

    @educational_periods_all = EducationalPeriod.order(:internal_order)
    @educational_periods = @educational_periods_all #.where("internal_order <= ?", educational_period_current.internal_order)

    @sub_grades_teacher = SubGradeTeacher.where("school_year_id = ?", get_current_school_year(@school_year_current)).pluck(:sub_grade_id)
    @sub_grades = SubGrade.where("id IN (?)", @sub_grades_teacher).order(:id)

    @educational_asignatures = EducationalAsignature.where("id = 0")

    @students = []
    if params[:commit] == "filter"
      puts "=========================="
      school_year_id         = params[:school_year_id]
      @sub_grade_id          = params[:sub_grade_id]

      # SE OBTIENEN LOS ALUMNOS
      @student_sub_grades = StudentSubGrade.where("sub_grade_id = ? AND school_year_id = ?", @sub_grade_id, school_year_id)
      @student_sub_grades_tmp = StudentSubGrade.where("sub_grade_id = ? AND school_year_id = ?", @sub_grade_id, school_year_id)
      @students = User.order(:last_name).where("id IN (?)", @student_sub_grades.pluck(:student_id))

      # SE OBTIENE EL PROGRESO DE LOS ESTUDIANTES
      @student_progresses = StudentProgress
                              .includes(:grade_asignature)
                              .where("
                                student_sub_grade_id IN (?)
                                AND school_year_id = ?
                                AND period_id <= ?
                                ",
                                @student_sub_grades.pluck(:id),
                                school_year_id,
                                @educational_period_id
                              )
                              .order('grade_asignatures.internal_order')

      @educational_asignatures = EducationalAsignature.where("id IN (?)", @student_progresses.pluck(:educational_asignature_id))
      puts ">>>>>>>>>>>>>>>>>>>>lasldklfjsd: #{@educational_asignatures.inspect}"
      @school_year_id = school_year_id
      # @student_progresses.where("student_progresses.period_id = ?", educational_period.id).each_with_index do |student, index|
      # end
    end
  end

  def update_asignatures
    # if current_user.role_id == 0 or current_user.role_id == 1
    #   @sub_grade_teachers = SubGradeTeacher.where("sub_grade_id = ? AND school_year_id = ?", params[:sg_id], params[:syid])
    #   @teacher_asignatures = TeacherAsignature.where("sub_grade_teacher_id IN (?)", @sub_grade_teachers.pluck(:id)).pluck(:educational_asignature_id)
    #   @educational_asignatures = EducationalAsignature.where("id IN (?)", @teacher_asignatures).order(:name)#.map { |e| [e.id, e.name] }
    # else
      @sub_grade_teacher = SubGradeTeacher.where("sub_grade_id = ? AND school_year_id = ?", params[:sg_id], params[:syid])
      puts ">>>>>>>>>>>>>>>>>>>>>>>>>@sub_grade_teacher: #{@sub_grade_teacher.inspect}"
      @teacher_asignatures = TeacherAsignature.where("sub_grade_teacher_id IN (?)", @sub_grade_teacher.pluck(:id)).pluck(:educational_asignature_id)
      @educational_asignatures = EducationalAsignature.where("id IN (?)", @teacher_asignatures).order(:name)#.map { |e| [e.id, e.name] }
    # end

    respond_to do |format|
      format.js
    end
  end

  def index
    @student_trackings = StudentTracking.all
    respond_with(@student_trackings)
  end

  def show
    respond_with(@student_tracking)
  end

  def new
    @educational_asignatures = EducationalAsignature.where("id = 0")
    @students = User.where("id = 0")
    # OBTENER EL PERIODO ACTUAL Y EL SELECT AUTOMÁTICO DEL PERIODO
    @educational_period_id_range = get_current_period()
    educational_period = EducationalPeriod.find(@educational_period_id_range)
    @educational_periods = EducationalPeriod.where("internal_order <= ?", educational_period.internal_order).order(:internal_order)

    if params[:commit] == "filter"
      # VARIABLES PARA MANTENER LOS CRITERIOS DEL FILTRO
      # Obtenemos el grado
      grade_id = SubGrade.find(params[:sub_grade_id]).grade_id
      school_year_id = params[:school_year_id]
      educational_asignature_id = params[:score_detail_educational_asignature_id]
      @educational_period_id = params[:educational_period_id]
      @sub_grade_id = params[:sub_grade_id]
      @score_detail_educational_asignature_id = params[:score_detail_educational_asignature_id]

      # SE MANTIENE EL COMBO DEPENDIENTE CON LOS VALORES SEGÚN EL CURSO ELEGIDO
      @sub_grade_teacher = SubGradeTeacher.where("school_year_id = ? AND sub_grade_id = ? AND teacher_id = ?", school_year_id, @sub_grade_id, current_user)

      @teacher_asignatures = TeacherAsignature.where("sub_grade_teacher_id = ?", get_sub_grade_teacher(@sub_grade_id, school_year_id, current_user)).pluck(:educational_asignature_id)
      @educational_asignatures = EducationalAsignature.where("id IN (?)", @teacher_asignatures).order(:name)

      # OBTENER LOS DETALLES DE ACTIVIDAD POR DESEMPEÑO O LOGRO
      # @eduper_score_details = ScoreDetail.where("school_year_id = ? AND sub_grade_teacher_id = ? AND educational_asignature_id = ? AND educational_period_id = ?", school_year_id, @sub_grade_teacher.last.id, @score_detail_educational_asignature_id, @educational_period_id)

      # SE OBTIENEN LAS ACTIVIDADES ASOCIADAS A LOS DESEMPEÑOS
      # Se obtiene el grade_asignature_id
      grade_asignature = GradeAsignature.where("school_year_id = ? AND grade_id = ? AND educational_asignature_id = ?", school_year_id, grade_id, educational_asignature_id).first
      # Se obtienen los desempeños para el curso y la asignatura filtrada
      @educational_performance_grades = EducationalPerformanceGrade.where("grade_asignature_id = ? AND educational_period_id = ?", grade_asignature.id, @educational_period_id)
      @eduper_score_details = EduperScoreDetail.where("educational_performance_grade_id IN (?) AND sub_grade_teacher_id = ?", @educational_performance_grades.map { |p| p.id }, @sub_grade_teacher.first.id)

      # puts "*****************@educational_performance_grades: #{@educational_performance_grades.pluck(:id)}"
      # puts "*****************@eduper_score_details: #{@eduper_score_details.pluck(:id)}"

      # Es obligatorio crear el campo de evaluación final autmáticamente que valga el 25% de la nota final
      # para el 2017 el valor de la nota de la evaluacion sera de 30%.

      weight_data = 25.0
      if school_year_id.to_i >= 3  # school_year_id = 3 para el 2017 en adelante
        weight_data = 30.0
      end

      # -- Se debe verificar si existe la evaluacion
      @flag_exist_field_evaluation = exist_field_evaluation(@educational_performance_grades, @sub_grade_teacher.first.id)
      unless @flag_exist_field_evaluation
        unless @educational_performance_grades.where("educational_performances_list_id = 1").any?
          @educational_performance_grade = EducationalPerformanceGrade.new

          @educational_performance_grade.educational_performances_list_id = 1 # Éste desempeño define la evaluación final
          @educational_performance_grade.grade_asignature_id = grade_asignature.id
          @educational_performance_grade.educational_period_id = @educational_period_id
          if @educational_performance_grade.save
            @eduper_score_detail = EduperScoreDetail.new
            @eduper_score_detail.name = "Eval Final"
            @eduper_score_detail.description = nil
            @eduper_score_detail.educational_performance_grade_id = @educational_performance_grade.id
            @eduper_score_detail.sd_detail_id = 2 # Éste detalle es el de evaluación final y es obligatorio que esté en 2
            @eduper_score_detail.sub_grade_teacher_id = @sub_grade_teacher.first.id
            @eduper_score_detail.weight = weight_data
            @eduper_score_detail.save
          end
          # puts "---------------Se crea la evaluación"
        else
          @eduper_score_detail = EduperScoreDetail.new
            @eduper_score_detail.name = "Eval Final"
            @eduper_score_detail.description = nil
            @eduper_score_detail.educational_performance_grade_id = @educational_performance_grades.where("educational_performances_list_id = 1").first.id
            @eduper_score_detail.sd_detail_id = 2 # Éste detalle es el de evaluación final y es obligatorio que esté en 2
            @eduper_score_detail.sub_grade_teacher_id = @sub_grade_teacher.first.id
            @eduper_score_detail.weight = weight_data
            @eduper_score_detail.save
            # puts "---------------Se crea la evaluación otra persona"
        end
      end
      # SE OBTIENEN LOS ALUMNOS
      @student_sub_grades = StudentSubGrade.where("sub_grade_id = ? AND school_year_id = ?", @sub_grade_id, school_year_id).pluck(:student_id)
      @student_sub_grades_tmp = StudentSubGrade.where("sub_grade_id = ? AND school_year_id = ?", @sub_grade_id, school_year_id)
      @students = User.order(:last_name).where("id IN (?)", @student_sub_grades)

      flag_change_rank = (@educational_period_id.to_i == get_current_period().to_i)
      # puts "::::::::::::::flag_change_rank: #{flag_change_rank}"

      # Posición del estudiante en el curso
      set_position_student_sub_grade(@student_sub_grades_tmp, @educational_period_id, flag_change_rank)
      @educational_period_id_range = @educational_period_id
    end
    @student_tracking = StudentTracking.new
    @school_year_current = Time.now.year
    @school_year = SchoolYear.where("name = '?'", @school_year_current).first
    @sub_grades_teacher = SubGradeTeacher.where("teacher_id = ? AND school_year_id = ?", current_user.id, get_current_school_year(@school_year_current)).pluck(:sub_grade_id)
    @sub_grades = SubGrade.where("id IN (?)", @sub_grades_teacher).order(:id)

    respond_with(@student_tracking)
  end

  def edit
  end

  def student_comment
    # # PROCESO PARA MIGRAR LOS COMENTARIOS DE LA TABLA STUDENT_PROGRESSES A student_comments
    # @student_progresses = StudentProgress.where("comments IS NOT NULL AND comments <> ''")
    # @student_progresses.each do |student_progress|
    #   @student_comments = StudentComment.where("student_sub_grade_id = ? AND educational_period_id = ?", student_progress.student_sub_grade_id, student_progress.period_id)

    #   if @student_comments.any?
    #     @student_comment = @student_comments.first
    #   else
    #     @student_comment = StudentComment.new
    #   end

    #   @student_comment.student_sub_grade_id = student_progress.student_sub_grade_id
    #   @student_comment.educational_period_id = student_progress.period_id
    #   @student_comment.comments = student_progress.comments.strip.capitalize
    #   @student_comment.save
    # end

    @school_year_current = Time.now.year
    @school_year = SchoolYear.where("name = '?'", @school_year_current).first
    # @sub_grades_teacher = SubGradeTeacher.where("teacher_id = ?", current_user.id).pluck(:sub_grade_id)
    #@sub_grades_tmp = SubGradeTeacher.where("teacher_id = ?", current_user.id)
    @sub_grades = SubGrade.where("course_director_id = ?", current_user.id).order(:id)
    # @educational_asignatures = EducationalAsignature.where("id = 0")

    @student_sub_grades = StudentSubGrade.where("sub_grade_id = ? AND school_year_id = ?", params[:sub_grade_id], @school_year.id).pluck(:student_id)
    @students = User.order(:last_name).where("id IN (?)", @student_sub_grades)

    # OBTENER EL PERIODO ACTUAL Y EL SELECT AUTOMÁTICO DEL PERIODO
    @educational_period_id_range = get_current_period()
    educational_period = EducationalPeriod.find(@educational_period_id_range)
    @educational_periods = EducationalPeriod.where("internal_order <= ?", educational_period.internal_order).order(:internal_order)

    if params[:flag_show_list].to_i == 1
      @sub_grade = SubGrade.find(params[:sub_grade_id])
      @grade_asignature = GradeAsignature.where("educational_asignature_id = ? and grade_id = ?", params[:score_detail_educational_asignature_id], @sub_grade.grade_id)
      @educational_performance = EducationalPerformance.where("educational_period_id = ? and grade_id = ? and educational_asignature_id = ? and school_year_id = ?", params[:educational_period_id], @sub_grade.grade_id, params[:score_detail_educational_asignature_id], params[:school_year_id])

      # Variables para student_progresses
      # @grade_asignature_id = @grade_asignature.last.id
      # @educational_performance_id = @educational_performance.last.id
      @educational_period_id = params[:educational_period_id]
      @sub_grade_id = @sub_grade.id

      # @student_progresses = StudentProgress.where("student_sub_grade_id IN (?) AND grade_asignature_id = ? AND educational_performance_id = ? AND period_id = ?", @student_sub_grades, @grade_asignature.last.id, @educational_performance.last.id, params[:educational_period_id])
      respond_to do |format|
        format.js
      end
    else
      respond_with(@student_tracking)
    end
  end

  def update_field_form
    @sub_grade_teacher = SubGradeTeacher.where("teacher_id = ? AND sub_grade_id = ?", current_user, params[:sub_grade_id])
    @score_details = ScoreDetail.where("school_year_id = ? AND sub_grade_teacher_id = ? AND educational_asignature_id = ? AND educational_period_id = ?", params[:year_actual], @sub_grade_teacher.last.id, params[:educational_asignature_id], params[:period_id])
    @student_sub_grades = StudentSubGrade.where("sub_grade_id = ?", params[:sub_grade_id]).pluck(:student_id)
    @students = User.order(:last_name).where("id IN (?)", @student_sub_grades)
    #@student_trackings = StudentTracking.where("user_id IN (?) AND score_detail_id IN (?)", @student_sub_grades, @score_details.pluck(:id))
    respond_to do |format|
      format.js
    end
  end

  def save_data
    @student_tracking = StudentTracking.where("user_id = ? AND eduper_score_detail_id = ?", params[:user_id], params[:eduper_score_detail_id])

    @flag_save = 0
    if @student_tracking.any?
      @student_tracking = StudentTracking.find(@student_tracking.last.id)
      if @student_tracking.score.to_f == params[:score]
        @flag_save = 1
      end
    else
      @student_tracking = StudentTracking.new
    end

    #if @flag_save == 0
      @student_tracking.user_id = params[:user_id]
      @student_tracking.eduper_score_detail_id = params[:eduper_score_detail_id]
      if params[:score].to_f == -1.0
        params[:score] = nil
        compliance = nil
      else
        @score_detail = EduperScoreDetail.find(params[:eduper_score_detail_id])

        if @score_detail.sd_detail_id == 2
          compliance = params[:score].to_f * @score_detail.weight.to_f / 100.0
        else
          compliance = params[:score].to_f * @score_detail.weight.to_f / 100.0
          puts "****************compliance: #{compliance}"
          educational_performance_grade = EducationalPerformanceGrade.find(@score_detail.educational_performance_grade_id)
          grade_asignature_id = educational_performance_grade.grade_asignature_id
          educational_period_id = educational_performance_grade.educational_period_id
          educational_performance_grades = EducationalPerformanceGrade.where("grade_asignature_id = ? AND educational_period_id = ?", grade_asignature_id, educational_period_id) # Se obtiene el total de desempeños o logros

          # Hallar todos los desempeños o logros que están siendo evaluados en el momento de calificar
          eduper_score_details = EduperScoreDetail.where("sd_detail_id <> 2 and educational_performance_grade_id IN (?)", educational_performance_grades.pluck(:id)) #.group(:educational_performance_grade_id)
          puts "_____________educational_performance_grades.size.to_f: #{educational_performance_grades.size.to_f}"
          percentage_data = 0.75
          if params[:school_year_id].to_i >= 3 # Se cambia el porcentaje para el 2017 y en adelante
            percentage_data = 0.7
          end
          compliance *= (percentage_data / educational_performance_grades.where("educational_performances_list_id <> 1").size.to_f)
        end
      end
      @student_tracking.score = params[:score]
      @student_tracking.compliance = compliance
      # puts "-----params[:score].to_f * @score_detail.weight.to_f / 100.0: #{params[:score].to_f * @score_detail.weight.to_f / 100.0}"

      @student_tracking.save
    #end
  end

  def update_scores_finals
    # puts ">>>>>>params[:sub_grade_id]: #{params[:sub_grade_id]}"
    # puts ">>>>>>params[:school_year_id]: #{params[:school_year_id]}"
    # puts ">>>>>>params[:educational_period_id]: #{params[:educational_period_id]}"
    # puts ">>>>>>params[:educational_asignature_id]: #{params[:educational_asignature_id]}"
    # puts ">>>>>>params[:user_id]: #{params[:user_id]}"
    @sub_grade_teacher = SubGradeTeacher.where("teacher_id = ? AND sub_grade_id = ? AND school_year_id = ?", current_user, params[:sub_grade_id], params[:school_year_id])

    @sub_grade = SubGrade.find(params[:sub_grade_id])
    @grade_asignature = GradeAsignature.where("educational_asignature_id = ? AND grade_id = ? AND school_year_id = ?", params[:educational_asignature_id], @sub_grade.grade_id, params[:school_year_id])
    @educational_performance_grades = EducationalPerformanceGrade.where("educational_period_id = ? and grade_asignature_id IN (?)", params[:educational_period_id], @grade_asignature.map { |g| g.id })

    @eduper_score_details = EduperScoreDetail.where("educational_performance_grade_id IN (?) AND sub_grade_teacher_id = ?", @educational_performance_grades.map { |e| e.id }, @sub_grade_teacher.last.id).order(:educational_performance_grade_id)

    @sumScorePercentage = 0
    @student_trackings = StudentTracking.where("user_id = ? AND eduper_score_detail_id IN (?)", params[:user_id], @eduper_score_details.pluck(:id))

    @student_trackings.where("score IS NOT NULL").each do |student_tracking|
      weight_detail = EduperScoreDetail.find(student_tracking.eduper_score_detail_id).weight.to_f
      @sumScorePercentage += student_tracking.score.to_f * weight_detail.to_f / 100.0
    end

    # # CALCULO NOTA ACUMULADA
    # @sumWeightNotNull = EduperScoreDetail.where("id IN (?)", @student_trackings.where("score IS NOT NULL").pluck(:eduper_score_detail_id)).sum(:weight).to_f

    # if @sumScorePercentage.to_f != 0.0
    #   @score_acum = (100 / @sumWeightNotNull) * @sumScorePercentage.to_f
    #   @score_acum = '%.1f' % ((@score_acum*10).round / 10.0)
    #   @color_class_acum = getColorClass(@score_acum)
    # else
    #   @score_acum = ""
    #   @color_class_acum = "colorGreenLight"
    # end

    # Esto lo hice el día 14 abr 2016
    # @eduper_score_details_without_eval = @eduper_score_details.where("sd_detail_id <> 2").group(:educational_performance_grade_id).size

    # @eduper_score_details_without_eval.each do |eduper_score_detail_without_eval|
    #   @student_trackings.where("score IS NOT NULL AND eduper_score_detail_id = ?", eduper_score_detail_without_eval)
    # end

    # CALCULO NOTA DEFINITIVA
    if @student_trackings.where("score IS NOT NULL").any?
      # puts ".........any"
      @score_def = '%.1f' % ((@student_trackings.sum(:compliance).to_f*10).round / 10.0)
      @color_class_def = getColorClass(@score_def)
    else
      # puts ".........no any"
      @score_def = ""
      @color_class_def = "colorOrangeLight"
    end
    puts "@score_def: #{@score_def}"

    # GUARDAR EN STUDENT_PROGRESSES PARA PODER GENERAR EL BOLETIN
    @student_sub_grade = StudentSubGrade.where("student_id = ? AND school_year_id = ? AND sub_grade_id = ?", params[:user_id], params[:school_year_id], params[:sub_grade_id]).last

    # @sub_grade = SubGrade.find(params[:sub_grade_id])
    # @grade_asignature = GradeAsignature.where("educational_asignature_id = ? AND grade_id = ? AND school_year_id = ?", params[:educational_asignature_id], @sub_grade.grade_id).last

    # @educational_performance = @educational_performance_grades.where("grade_asignature_id = ?", @grade_asignature.last.id)
    # puts "+++++++++++@educational_performance: #{@educational_performance.map { |e| e.id }}"

    # Variables student_progresses
    student_sub_grade_id = @student_sub_grade.id
    grade_asignature_id = @grade_asignature.first.id
    educational_asignature_id = params[:educational_asignature_id]
    educational_performance_id = nil # @educational_performance.id  Es null porque no es solo uno con ; sino varios desempeños separados como registros
    period_id = params[:educational_period_id]
    score = @score_def
    log = "Ingreso de calificación realizada por #{current_user.complete_name} / #{Time.now.strftime("%Y-%m-%d")}: calificación:  #{@score_def}"
    comments = ""

    # Guardar información en student_progresses
    @student_progresses = StudentProgress.where("student_sub_grade_id = ? AND grade_asignature_id = ? AND educational_asignature_id = ? AND period_id = ?", student_sub_grade_id, grade_asignature_id, educational_asignature_id, period_id)

    @flag_save_progress = 0
    if @student_progresses.any?
      @student_progress = StudentProgress.find(@student_progresses.last.id)
      if score != ""
        if @student_progress.score.to_f == score.to_f
          @flag_save_progress = 1
        end
      else
        score = 0.0
      end
    else
      @student_progress = StudentProgress.new
    end

    if @flag_save_progress == 0
      @student_progress.student_sub_grade_id = student_sub_grade_id
      @student_progress.grade_asignature_id = grade_asignature_id
      @student_progress.educational_asignature_id = educational_asignature_id
      @student_progress.educational_performance_id = educational_performance_id
      @student_progress.period_id = period_id
      @student_progress.score = score
      @student_progress.log = log
      @student_progress.comments = comments

      # Calcula la posición del estudiante en el curso
      @student_sub_grades = StudentSubGrade.where("school_year_id = ? AND sub_grade_id = ?", params[:school_year_id], params[:sub_grade_id])
      # set_position_student_sub_grade(@student_sub_grades, period_id)
      #
      @student_progress.student_sub_grades = @student_sub_grades
      @student_progress.educational_period_id = period_id
      @student_progress.flag_change_rank = (period_id.to_i == get_current_period().to_i)
      # puts "despues+++++++++++++@student_progress: #{@student_progress.inspect}"
      # puts ".....................flag_change_rank: #{@flag_change_rank}"
      @student_progress.save
    end

    respond_to do |format|
      format.js
    end
  end

  def save_comment
    # GUARDAR EN STUDENT_COMMENTS LOS COMENTARIOS
    @student_sub_grade = StudentSubGrade.where("student_id = ? AND school_year_id = ? AND sub_grade_id = ?", params[:user_id], params[:school_year_id], params[:sub_grade_id]).last

    @sub_grade = SubGrade.find(params[:sub_grade_id])
    # @grade_asignature = GradeAsignature.where("educational_asignature_id = ? AND grade_id = ?", params[:educational_asignature_id], @sub_grade.grade_id).last

    # @educational_performance = EducationalPerformance.where("educational_period_id = ? AND grade_id = ? AND educational_asignature_id = ? AND school_year_id = ?", params[:educational_period_id], @sub_grade.grade_id, params[:educational_asignature_id], params[:school_year_id]).last

    # Guardar información en student_progresses
    student_sub_grade_id = @student_sub_grade.id
    # grade_asignature_id = @grade_asignature.id
    # educational_asignature_id = params[:educational_asignature_id]
    # educational_performance_id = @educational_performance.id
    educational_period_id = params[:educational_period_id]

    @student_comments = StudentComment.where("student_sub_grade_id = ? AND educational_period_id = ?", student_sub_grade_id, educational_period_id)

    # Variables student_progresses
    if @student_comments.any?
      @student_comment = @student_comments.first
    else
      @student_comment = StudentComment.new
    end

    log = "Ingreso de comentario realizado por #{current_user.complete_name} / #{Time.now.strftime("%Y-%m-%d")}: comentario:  #{params[:comment]}"
    @student_comment.student_sub_grade_id = student_sub_grade_id
    @student_comment.educational_period_id = educational_period_id
    @student_comment.comments = params[:comment].strip.capitalize
    @student_comment.save
  end

  def create
    @student_tracking = StudentTracking.new(student_tracking_params)
    @student_tracking.save
    respond_with(@student_tracking)
  end

  def update
    @student_tracking.update(student_tracking_params)
    respond_with(@student_tracking)
  end

  def destroy
    @student_tracking.destroy
    respond_with(@student_tracking)
  end

  # FUNCIONES ESPECIALES ======================
  def getColorClass(score)
    if score.to_f >= 0.0 and score.to_f <= 3.2
      classColor = "colorRed"
    elsif score.to_f >= 3.3 and score.to_f <= 3.9
      classColor = "colorOrange"
    elsif score.to_f >= 4.0 and score.to_f <= 4.5
      classColor = "colorYellow"
    elsif score.to_f >= 4.6 and score.to_f <= 5
      classColor = "colorGreen"
    end

    return classColor
  end

  def exist_field_evaluation(performances, sub_grade_teacher_id)
    if performances.where("educational_performances_list_id = 1").any?
      if EduperScoreDetail.where("sub_grade_teacher_id = ? AND sd_detail_id = 2 AND educational_performance_grade_id = ?", sub_grade_teacher_id, performances.where("educational_performances_list_id = 1").first.id).any?
        return true
      else
        return false
      end
    else
      return false
    end
  end

  def set_position_student_sub_grade(student_sub_grades, educational_period_id, flag_change_rank)
    # Llenará la table de average_student_sub_grade quien determinará el puesto del estudiante en el curso
    Rails.logger.info "*********ingresa a set_position_student_sub_grade controller"
    if flag_change_rank
      student_sub_grades.each do |student_sub_grade|
        student_progresses_average = StudentProgress.where("student_sub_grade_id = ? AND period_id = ?", student_sub_grade.id, educational_period_id).average(:score)
          if AverageStudentSubGrade.where("student_sub_grade_id = ? AND educational_period_id = ?", student_sub_grade.id, educational_period_id).any?
            @average_student_sub_grade = AverageStudentSubGrade.where("student_sub_grade_id = ? AND educational_period_id = ?", student_sub_grade.id, educational_period_id).first
          else
            @average_student_sub_grade = AverageStudentSubGrade.new
            @average_student_sub_grade.student_sub_grade_id = student_sub_grade.id
            @average_student_sub_grade.educational_period_id = educational_period_id
          end

          @average_student_sub_grade.average = student_progresses_average.to_f
          @average_student_sub_grade.save
      end

      @average_student_sub_grades = AverageStudentSubGrade.where("student_sub_grade_id IN (?) AND educational_period_id = ?", student_sub_grades.pluck(:id), educational_period_id).order("average desc, id asc")

      @average_student_sub_grades.each_with_index do |average_student_sub_grade, index|
        average_student_sub_grade.update_attribute(:place, index + 1)
      end
    end
  end
  # ===========================================

  private
    def set_student_tracking
      @student_tracking = StudentTracking.find(params[:id])
    end

    def student_tracking_params
      params.require(:student_tracking).permit(:score_detail_id, :educational_period_id, :score, :compliance)
    end
end
