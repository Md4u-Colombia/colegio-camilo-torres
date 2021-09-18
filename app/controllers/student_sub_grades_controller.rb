class StudentSubGradesController < ApplicationController
  load_and_authorize_resource :except => [:create,:add_score]
  before_action :set_student_sub_grade, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def add_score
    flash[:success] = ""
    @student_progresses = StudentSubGrade.find(params[:sg_id])
    @sub_grade = SubGrade.find(@student_progresses.sub_grade_id)
    @gradeasignature = GradeAsignature.where("grade_id=?",@sub_grade.grade_id).order("internal_order")
    @student = User.find(@student_progresses.student_id).complete_name
    @student_progress = StudentProgress.new
    if(params[:commit].to_s == "Buscar")
      date_now = Time.now
      date_nown = date_now.strftime("%Y-%m-%d")
      @educational_performances = EducationalPerformance.where("educational_period_id=? AND grade_id=?",params[:add_score][:period_id], @sub_grade.grade_id).order("grade_id,educational_period_id,educational_asignature_id")
      if(params[:add_score][:educational_asignature_id].to_i > 0)
        @educational_performances = @educational_performances.where("educational_asignature_id=?",params[:add_score][:educational_asignature_id].to_i)
      end
    end
    if(params[:commit].to_s == "Guardar")
      date_now = Time.now
      date_nown = date_now.strftime("%Y-%m-%d")
      student_sub_grade_id = params[:sg_id]
      grade_id = params[:hgrade_id]
      educational_asignature_id = params[:heducational_asignature_id]
      educational_performance_id = params[:heducational_performance_id]
      period_id = params[:heducational_period_id]
      score = params[:score]
      comment = params[:comments]
      flash[:success] = ""
      log = ""
      for s in 0...score.size
        grade_asignature =  GradeAsignature.where("educational_asignature_id=? AND grade_id=?",educational_asignature_id[s],grade_id[s]).first
        @student_progressesf = StudentProgress.where("period_id=? AND educational_performance_id=? AND educational_asignature_id=? AND grade_asignature_id=? AND student_sub_grade_id=?",period_id[s].to_i,educational_performance_id[s].to_i,educational_asignature_id[s].to_i,grade_asignature.id,student_sub_grade_id)
        unless(@student_progressesf.any?)
          if(score[s].to_f != 0.0)
            @student_progress = StudentProgress.new
            @student_progress.student_sub_grade_id = student_sub_grade_id
            @student_progress.grade_asignature_id = grade_asignature.id
            @student_progress.educational_asignature_id = educational_asignature_id[s].to_i
            @student_progress.educational_performance_id = educational_performance_id[s].to_i
            @student_progress.period_id = period_id[s].to_i
            @student_progress.score = score[s].to_f
            if(comment[s].to_s != "")
              commentss = comment[s].to_s
            else
              commentss = " "
            end
            @student_progress.comments = commentss.to_s
            log = "Ingreso de calificación realizada por #{current_user.complete_name} / #{date_nown}: calificación:  #{score[s].to_f}"
            @student_progress.log = log.to_s
            if(@student_progress.save)
              flash[:success] = "<i class='fa fa-check-circle fa-2x'></i>&nbsp;Los datos han sido guardados exitosamente.".html_safe
            end
          end
        else
          if(comment[s].to_s != "")
            commentss = comment[s].to_s
          else
            commentss = " "
          end
          if(score[s].to_f != 0.0)
            calificacion_ant  = @student_progressesf.map { |s| s.score}[0].to_f
            if(calificacion_ant.to_f != score[s].to_f)
              @student_progressesf.first.update_attribute(:score,score[s].to_f)
              log = @student_progressesf.map { |s| s.log}[0].to_s+" / Modificación de calificación realizada por #{current_user.complete_name} / #{date_nown}: calificación: #{calificacion_ant} por #{score[s].to_f}"
              @student_progressesf.first.update_attribute(:log,log.to_s)
              flash[:success] = "<i class='fa fa-check-circle fa-2x'></i>&nbsp;Los datos han sido guardados exitosamente.".html_safe
            end
            @student_progressesf.first.update_attribute(:comments,commentss.to_s)
          end
        end
      end
    end
    #render :layout => false
  end

  def index
    @student_sub_grades = StudentSubGrade.order("sub_grade_id")
     if(current_user.role_id == 2)
      @search = @student_sub_grades.where("sub_grade_id=?",params[:ssg_id]).search(params[:q])
      @student_sub_grades = @search.result.page(params[:page]).per(60)
    else
      @search = @student_sub_grades.where("sub_grade_id=?",params[:ssg_id]).search(params[:q])
      @student_sub_grades = @search.result.page(params[:page]).per(60)
    end
    respond_with(@student_sub_grades)
  end

  def show
    @student_sub_grade
    render :layout => false
  end

  def new
    @student_sub_grade = StudentSubGrade.new
    @search = StudentSubGrade.order("sub_grade_id, school_year_id DESC").search(params[:q])
    @student_sub_grades = @search.result.includes(:sub_grade).page(params[:page]).per(30)
    respond_with(@student_sub_grade)
  end

  def edit
    @search = StudentSubGrade.search(params[:q])
    @student_sub_grades = @search.result.page(params[:page]).per(30)
  end

  def create
    #if(exist_student_sub_grade(params[:student_sub_grade][:students_grade_id]).blank?)
    if(StudentSubGrade.where("student_id=? AND school_year_id=?",params[:student_sub_grade][:student_id],params[:student_sub_grade][:school_year_id]).blank?)
      @student_sub_grade = StudentSubGrade.new(student_sub_grade_params)
      @student_sub_grade.course_director_id = SubGrade.find(params[:student_sub_grade][:sub_grade_id]).course_director_id
      if @student_sub_grade.save
        flash[:notice] = 'La asignación se realizó satisfactoriamente.'
      else
        @search = StudentSubGrade.search(params[:q])
        @student_sub_grades = @search.result.page(params[:page]).per(30)
      end
    else
      #student_sub_grade = exist_student_sub_grade(params[:student_sub_grade][:students_grade_id]).last.id
      student_sub_grade = StudentSubGrade.where("student_id=? AND school_year_id=?",params[:student_sub_grade][:student_id],params[:student_sub_grade][:school_year_id]).last.id
      @student_sub_grade = StudentSubGrade.find(student_sub_grade)
      @student_sub_grade.course_director_id = SubGrade.find(params[:student_sub_grade][:sub_grade_id]).course_director_id
      if @student_sub_grade.update(student_sub_grade_params)
        flash[:notice] = 'La asignación se actualizó satisfactoriamente.'
      else
        flash[:notice] = 'La asignación ya se encuentra realizada.'
      end
    end
    respond_with(@student_sub_grade)
  end

  def update
    unless @student_sub_grade.update(student_sub_grade_params)
      @search = StudentSubGrade.search(params[:q])
      @student_sub_grades = @search.result.page(params[:page]).per(30)
    end
    respond_with(@student_sub_grade)
  end

  def destroy
    @student_sub_grade.destroy
    respond_with(@student_sub_grade)
  end

  private
    def set_student_sub_grade
      @student_sub_grade = StudentSubGrade.find(params[:id])
    end

    def student_sub_grade_params
      params.require(:student_sub_grade).permit(:student_id, :school_year_id, :sub_grade_id, :students_grade_id, :course_director_id, :student_promoted)
    end
end
