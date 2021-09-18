class EducationalPerformanceGradesController < ApplicationController
  load_and_authorize_resource :except => [:create,:update_educational_asignature]
  before_action :set_educational_performance_grade, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index

    #@filter_educational_performances = EducationalAsignature.includes(:educational_area).order( 'educational_areas.education_level_id' )
    @filter_educational_performances = EducationalAsignature.order( 'educational_area_id' )

    @educational_performance_grades = EducationalPerformanceGrade.includes(:grade_asignature, :educational_performances_list).order("grade_id,educational_period_id,educational_asignature_id")
    #@educational_performance_grades = @educational_performance_grades.order("school_year_id DESC")

    @grades = Grade.order("education_level_id")
    if(current_user.role_id == 2)
      @sub_grade = SubGrade.where("course_director_id=?",current_user.id)
      @educational_performance_grades = @educational_performance_grades.where("grade_id IN (?)",@sub_grade.map{|s| s.grade}.uniq)
      @grades = @grades.where("id IN (?)",@sub_grade.map{|s| s.grade}.uniq)

      @filter_educational_performances = GradeAsignature.where("grade_id IN (?)",@sub_grade.map{|s| s.grade}.uniq)

    end
    @search = @educational_performance_grades.search(params[:q])
    @educational_performance_grades = @search.result.page(params[:page]).per(30)
    respond_with(@educational_performance_grades)
  end

  def duplicate_educational_performance_grades
    @last_school_year_id = get_current_school_year(Time.now.year - 1).id
    @school_year_id = get_current_school_year(Time.now.year).id
    @educational_period_id = get_current_period()
    period_name = EducationalPeriod.find(@educational_period_id).name
    @grade_asignature_list = GradeAsignature.where(
      'id IN (?) AND school_year_id = ?', 
      EducationalPerformanceGrade.where('grade_asignature_id IS NOT NULL AND educational_performances_list_id <> 1 AND educational_period_id = ?', @educational_period_id).map { |e| e.grade_asignature_id}.uniq,
      @school_year_id
    ).select('DISTINCT grade_id')
    @grades = Grade.where('id NOT IN (?)', @grade_asignature_list)
    puts "@grades => #{@grades.any? }"
    unless @grades.any?
      @grades = Grade.all
    end
    if params[:button] == 'duplicate'
      grade_id = params[:from_grade_id]
      array_grade_asignature = Array.new
      GradeAsignature.where(school_year_id: params[:from_school_year_id], grade_id: grade_id).each do |grade_asignature|
        array_grade_asignature << grade_asignature.id
      end
      grade_asignatures =  GradeAsignature.where(school_year_id: params[:to_school_year_id], grade_id: grade_id)
      msg = ''
      if grade_asignatures.any?
        grade_asignatures.each_with_index do |grade_asignature, i|
          educational_performance_grades = EducationalPerformanceGrade.where(
            'educational_performances_list_id <> 1 AND grade_asignature_id = ? AND educational_period_id = ?', grade_asignature.id, params[:to_educational_period_id]
          )
          puts "educational_performance_grades => #{educational_performance_grades.size}"
          educational_performance_grades.each do |educational_performance_grade|
            exist_educational_performance_grade = EducationalPerformanceGrade.where(
              educational_performances_list_id: educational_performance_grade.educational_performances_list_id,
              grade_asignature_id: array_grade_asignature[i],
              educational_period_id: params[:from_educational_period_id]
            )
            unless exist_educational_performance_grade.any?
              educational_performance_grade_new = EducationalPerformanceGrade.new
              educational_performance_grade_new.educational_performances_list_id = educational_performance_grade.educational_performances_list_id
              educational_performance_grade_new.grade_asignature_id = array_grade_asignature[i]
              educational_performance_grade_new.educational_period_id = params[:from_educational_period_id]
              educational_performance_grade_new.created_at = Time.now
              educational_performance_grade_new.updated_at = Time.now
              educational_performance_grade_new.save
              EducationalPerformanceGrade.where('grade_asignature_id IS NULL AND educational_period_id = ?', params[:from_educational_period_id]).delete_all
              msg = "Desempeños del #{period_name} periodo han sido duplicados exitosamente."
            else
              msg = "Los Desempeños del #{period_name} periodo ya existen para este grado"
            end
          end
        end
      else
        msg = "No hay Grados Asignaturas para duplicar"
      end
      if !msg.blank?
        flash[:notice] = msg
        msg = ''
        redirect_to url_for(:action => :duplicate_educational_performance_grades)
      end

    end

  end

  def show
    respond_with(@educational_performance)
  end

  def new
    # Obtener el id del año actual y definirlo por default en el formulario
    @school_year_id = get_current_school_year(Time.now.year).id

    # Obtener el id del periodo en curso y definirlo por default en el formulario
    # OBTENER EL PERIODO ACTUAL Y EL SELECT AUTOMÁTICO DEL PERIODO
    @educational_period_id = get_current_period()
    educational_period = EducationalPeriod.find(@educational_period_id)
    @educational_periods = EducationalPeriod.where("internal_order <= ?", educational_period.internal_order).order(:internal_order)

    @update_educational_asignature = GradeAsignature.where("grade_id=0")
    @filter_educational_performances = EducationalAsignature.order( 'educational_area_id' )
    @educational_performance_grades = EducationalPerformanceGrade.includes(:educational_performances_list).order(" educational_period_id")
    @grades = Grade.order("education_level_id")
    @educational_performances_lists = EducationalPerformancesList.where("status = 1 and id <> 1").order(:name) # ALERTA: En éste caso se pone que el id sea diferente de uno, ya que se reailzó una modificación porque ya existían unos desempeños que funcionaban con separación de (;) usado porque se necesitaba lanzar rapidamente el tema de boletines y que no dificultara el proceso.
    if(current_user.role_id == 2)
      sub_grade = SubGrade.where("course_director_id = ?", current_user.id)

      if sub_grade.any? and false # Directores de curso 
        grade_asignatures = GradeAsignature.where("grade_id IN (?) AND school_year_id = ?", sub_grade.map{|s| s.grade}.uniq, @school_year_id)
        grades = @grades.where("id IN (?)", sub_grade.map{|s| s.grade}.uniq)
      else # Docentes
        sub_grade_teachers = SubGradeTeacher.where("teacher_id = ? AND school_year_id = ?", current_user.id, get_current_school_year(Time.now.year))
        @teacher_asignatures = TeacherAsignature.where("sub_grade_teacher_id IN (?)", sub_grade_teachers.pluck(:id))
        grades = @grades.where("id IN (?)", SubGrade.where("id IN (?)", sub_grade_teachers.pluck(:sub_grade_id)).pluck(:grade_id))
        grade_asignatures = GradeAsignature.where("educational_asignature_id IN (?) AND grade_id IN (?) AND school_year_id = ?", @teacher_asignatures.pluck(:educational_asignature_id), grades.pluck(:id), get_current_school_year(Time.now.year).id)
      end
      @educational_performance_grades = @educational_performance_grades.where("grade_asignature_id IN (?) AND educational_performances_list_id <> 1", grade_asignatures.map{|s| s.id}.uniq)

      @filter_educational_performances = GradeAsignature.where("grade_id IN (?) AND school_year_id = ?", sub_grade.map{|s| s.grade}.uniq, get_current_school_year(Time.now.year))
    end
    @search = @educational_performance_grades.search(params[:q])
    @educational_performance_grades = @search.result.page(params[:page]).per(30)

    @educational_performance_grade = EducationalPerformanceGrade.new
    respond_with(@educational_performance_grade)
  end

  def edit
    @school_year_id = set_educational_performance_grade.grade_asignature.school_year_id
    @educational_period_id = set_educational_performance_grade.educational_period_id
    @grade_id = set_educational_performance_grade.grade_asignature.grade_id
    @educational_asignature_id = set_educational_performance_grade.grade_asignature.educational_asignature_id

    @educational_period_id = get_current_period()
    educational_period = EducationalPeriod.find(@educational_period_id)
    @educational_periods = EducationalPeriod.where("internal_order <= ?", educational_period.internal_order).order(:internal_order)

    @update_educational_asignature = EducationalAsignature.where("id IN (?)", GradeAsignature.where("grade_id = ?", GradeAsignature.find(set_educational_performance_grade.grade_asignature_id).grade_id).map { |ga| ga.educational_asignature_id })
    @filter_educational_performances = EducationalAsignature.order( 'educational_area_id' )
    @educational_performance_grades = EducationalPerformanceGrade.order(" educational_period_id")
    @grades = Grade.order("education_level_id")
    @educational_performances_lists = EducationalPerformancesList.where("status = 1 and id <> 1").order(:description) # ALERTA: En éste caso se pone que el id sea diferente de uno, ya que se reailzó una modificación porque ya existían unos desempeños que funcionaban con separación de (;) usado porque se necesitaba lanzar rapidamente el tema de boletines y que no dificultara el proceso.
    if(current_user.role_id == 2)
      @sub_grade = SubGrade.where("course_director_id=?",current_user.id)
      @educational_performance_grades = @educational_performance_grades.where("grade_id IN (?)",@sub_grade.map{|s| s.grade}.uniq)
      @grades = @grades.where("id IN (?)",@sub_grade.map{|s| s.grade}.uniq)

      @filter_educational_performances = GradeAsignature.where("grade_id IN (?) AND school_year_id = ?", @sub_grade.map{|s| s.grade}.uniq, set_educational_performance_grade.school_year_id)
    end
    @search = @educational_performance_grades.search(params[:q])
    @educational_performance_grades = @search.result.page(params[:page]).per(30)
  end

  def create
    @update_educational_asignature = GradeAsignature.where("grade_id= #{params[:grade_id].to_i}")
    @filter_educational_performances = EducationalAsignature.order( 'educational_area_id' )
    @educational_performances = EducationalPerformance.order("grade_id,educational_period_id,educational_asignature_id")
    @grades = Grade.order("education_level_id")
    if(current_user.role_id == 2)
      @sub_grade = SubGrade.where("course_director_id=?",current_user.id)
      @educational_performances = @educational_performances.where("grade_id IN (?)",@sub_grade.map{|s| s.grade}.uniq)
      @grades = @grades.where("id IN (?)",@sub_grade.map{|s| s.grade}.uniq)

      @filter_educational_performances = GradeAsignature.where("grade_id IN (?)",@sub_grade.map{|s| s.grade}.uniq)
    end
    @search = @educational_performances.search(params[:q])
    @educational_performances = @search.result.page(params[:page]).per(30)

    str_errors=0
    str_msg = ""
    params[:chk][:performance].each do |performance|
      if(EducationalPerformance.where("educational_asignature_id = ? AND grade_id = ? AND educational_period_id = ? AND educational_performances_list_id = ?",params[:educational_asignature_id], params[:grade_id], params[:educational_performance_grade][:educational_period_id], performance).any?)
        str_msg += '<i class="fa fa-hand-o-right"></i>&nbsp;Ya se encuentra creada la asignación que esta realizando.<br>'
        str_errors +=1
      end
    end
    #str_errors = 0 # POR AHORA***************
    if(str_errors.to_i > 0)
      flash[:error] = str_msg.to_s
      redirect_to url_for(:action => :new)
    else

      params[:chk][:performance].each do |performance|
        params[:educational_performance_grade][:grade_asignature_id] = GradeAsignature.where("grade_id = ? AND educational_asignature_id = ? AND school_year_id = ?", params[:grade_id], params[:educational_asignature_id], params[:school_year_id]).first.id
        @educational_performance = EducationalPerformanceGrade.new(educational_performance_grade_params)
        @educational_performance.educational_performances_list_id = performance.to_i
        @educational_performance.save

        grade_asignature = GradeAsignature.where("grade_id = ? AND educational_asignature_id = ?", params[:grade_id].to_i, params[:educational_asignature_id].to_i).first
        @update_performances_lists = EducationalPerformancesList.where("grade_asignature_id IS NOT NULL AND grade_asignature_id = ?", grade_asignature.id).order(:description)
        @checks_selected = params[:chk][:performance]
      end
      respond_with(@educational_performance_grade, location: new_educational_performance_grade_url)
    end
  end

  def update
    @update_educational_asignature = GradeAsignature.where("grade_id=#{params[:educational_performance][:grade_id].to_i}")
    @filter_educational_performances = EducationalAsignature.order( 'educational_area_id' )
    @educational_performances = EducationalPerformance.order("grade_id,educational_period_id,educational_asignature_id")
    @grades = Grade.order("education_level_id")
    if(current_user.role_id == 2)
      @sub_grade = SubGrade.where("course_director_id=?",current_user.id)
      @educational_performances = @educational_performances.where("grade_id IN (?)",@sub_grade.map{|s| s.grade}.uniq)
      @grades = @grades.where("id IN (?)",@sub_grade.map{|s| s.grade}.uniq)

      @filter_educational_performances = GradeAsignature.where("grade_id IN (?)",@sub_grade.map{|s| s.grade}.uniq)
    end
    @search = @educational_performances.search(params[:q])
    @educational_performances = @search.result.page(params[:page]).per(30)

    #str_errors=0
    #str_msg = ""
    #if(EducationalPerformance.where("educational_asignature_id=? AND grade_id=? AND educational_period_id=?",params[:educational_performance][:educational_asignature_id],params[:educational_performance][:grade_id],params[:educational_performance][:educational_period_id]).any?)
      #str_msg += '<i class="fa fa-hand-o-right"></i>&nbsp;Ya se encuentra creada la asignación que esta realizando.<br>'
      #str_errors +=1
    #end
    #if(str_errors.to_i > 0)
      #flash[:error] = str_msg.to_s
      #redirect_to url_for(:action => :new)
    #else
    @educational_performance.update(educational_performance_params)
    respond_with(@educational_performance, location: new_educational_performance_url)
    #end
  end

  def destroy
    @filter_educational_performances = EducationalAsignature.order( 'educational_area_id' )
    @educational_performances = EducationalPerformance.order("grade_id,educational_period_id,educational_asignature_id")
    @grades = Grade.order("education_level_id")
    if(current_user.role_id == 2)
      @sub_grade = SubGrade.where("course_director_id=?",current_user.id)
      @educational_performances = @educational_performances.where("grade_id IN (?)",@sub_grade.map{|s| s.grade}.uniq)
      @grades = @grades.where("id IN (?)",@sub_grade.map{|s| s.grade}.uniq)

      @filter_educational_performances = GradeAsignature.where("grade_id IN (?)",@sub_grade.map{|s| s.grade}.uniq)
    end
    @search = @educational_performances.search(params[:q])
    @educational_performances = @search.result.page(params[:page]).per(30)
    @educational_performance = EducationalPerformanceGrade.find(params[:id])
    @educational_performance.destroy
    respond_with(@educational_performance, location: new_educational_performance_grade_url)
  end

  def update_educational_asignature
    @update_educational_asignature = GradeAsignature.where("grade_id = ? AND school_year_id = ?", params[:gid], params[:syid])
    respond_to do |format|
      format.js
    end
  end

  def update_performances_lists
    update_performances_list = EducationalPerformancesList.where("grade_id = ?", params[:gid])

    # Obtener lista de desempeños ya asignados a curso y asignatura
    grade_asignature_id = GradeAsignature.where("grade_id = ? AND educational_asignature_id = ? AND school_year_id = ?", params[:gid], params[:eaid], params[:syid]).first.id
    assigned_performances = EducationalPerformanceGrade.where("grade_asignature_id = ? AND educational_period_id = ?", grade_asignature_id, params[:epid])

    # ********* Ésto de quitarse para otro colegio pues solo es para camilo torres
    update_performances_list = update_performances_list.where("id <> 1")
    # ********************************************************************

    update_performances_list = update_performances_list.order(:description)

    # if update_performances_lists.any?
      render partial: "update_performances_lists", locals: { update_performances_lists: update_performances_list, assigned_performances: assigned_performances }
    # end
  end

  private
    def set_educational_performance_grade
      @educational_performance_grade = EducationalPerformanceGrade.find(params[:id])
    end

    def educational_performance_grade_params
      params.require(:educational_performance_grade).permit(:educational_performances_list_id, :grade_asignature_id, :educational_period_id)
    end
end
