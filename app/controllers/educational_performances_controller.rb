class EducationalPerformancesController < ApplicationController
  load_and_authorize_resource :except => [:create,:update_educational_asignature]
  before_action :set_educational_performance, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index

    #@filter_educational_performances = EducationalAsignature.includes(:educational_area).order( 'educational_areas.education_level_id' )
    @filter_educational_performances = EducationalAsignature.order( 'educational_area_id' )

    @educational_performances = EducationalPerformance.order("grade_id,educational_period_id,educational_asignature_id")
    @educational_performances = @educational_performances.order("school_year_id DESC")

    @grades = Grade.order("education_level_id")
    if(current_user.role_id == 2)
      @sub_grade = SubGrade.where("course_director_id=?",current_user.id)
      @educational_performances = @educational_performances.where("grade_id IN (?)",@sub_grade.map{|s| s.grade}.uniq)
      @grades = @grades.where("id IN (?)",@sub_grade.map{|s| s.grade}.uniq)

      @filter_educational_performances = GradeAsignature.where("grade_id IN (?)",@sub_grade.map{|s| s.grade}.uniq)

    end
    @search = @educational_performances.search(params[:q])
    @educational_performances = @search.result.page(params[:page]).per(30)
    respond_with(@educational_performances)
  end

  def show
    respond_with(@educational_performance)
  end

  def new
    @update_educational_asignature = GradeAsignature.where("grade_id=0")
    @filter_educational_performances = EducationalAsignature.order( 'educational_area_id' )
    @educational_performances = EducationalPerformance.order("school_year_id DESC, grade_id,educational_period_id,educational_asignature_id")
    @grades = Grade.order("education_level_id")
    @educational_performances_lists = EducationalPerformancesList.where("status = 1 and id <> 1").order(:name) # ALERTA: En éste caso se pone que el id sea diferente de uno, ya que se reailzó una modificación porque ya existían unos desempeños que funcionaban con separación de (;) usado porque se necesitaba lanzar rapidamente el tema de boletines y que no dificultara el proceso.
    if(current_user.role_id == 2)
      @sub_grade = SubGrade.where("course_director_id = ?", current_user.id)
      @educational_performances = @educational_performances.where("grade_id IN (?)",@sub_grade.map{|s| s.grade}.uniq)
      @grades = @grades.where("id IN (?)",@sub_grade.map{|s| s.grade}.uniq)

      @filter_educational_performances = GradeAsignature.where("grade_id IN (?) AND school_year_id = ?", @sub_grade.map{|s| s.grade}.uniq, get_current_school_year(Time.now.year))
    end
    @search = @educational_performances.search(params[:q])
    @educational_performances = @search.result.page(params[:page]).per(30)

    @educational_performance = EducationalPerformance.new
    respond_with(@educational_performance)
  end

  def edit
    @update_educational_asignature = GradeAsignature.where("grade_id=#{set_educational_performance.grade_id}")
    @filter_educational_performances = EducationalAsignature.order( 'educational_area_id' )
    @educational_performances = EducationalPerformance.order("grade_id,educational_period_id,educational_asignature_id")
    @grades = Grade.order("education_level_id")
    @educational_performances_lists = EducationalPerformanceList.where("status = 1 and id <> 1").order(:name) # ALERTA: En éste caso se pone que el id sea diferente de uno, ya que se reailzó una modificación porque ya existían unos desempeños que funcionaban con separación de (;) usado porque se necesitaba lanzar rapidamente el tema de boletines y que no dificultara el proceso.
    if(current_user.role_id == 2)
      @sub_grade = SubGrade.where("course_director_id=?",current_user.id)
      @educational_performances = @educational_performances.where("grade_id IN (?)",@sub_grade.map{|s| s.grade}.uniq)
      @grades = @grades.where("id IN (?)",@sub_grade.map{|s| s.grade}.uniq)

      @filter_educational_performances = GradeAsignature.where("grade_id IN (?)",@sub_grade.map{|s| s.grade}.uniq)
    end
    @search = @educational_performances.search(params[:q])
    @educational_performances = @search.result.page(params[:page]).per(30)
  end

  def create
    @update_educational_asignature = GradeAsignature.where("grade_id= #{params[:educational_performance][:grade_id].to_i}")
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
      if(EducationalPerformance.where("educational_asignature_id=? AND grade_id=? AND educational_period_id=? AND educational_performances_list_id = ?",params[:educational_performance][:educational_asignature_id],params[:educational_performance][:grade_id],params[:educational_performance][:educational_period_id], performance).any?)
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
        @educational_performance = EducationalPerformance.new(educational_performance_params)
        @educational_performance.educational_performances_list_id = performance.to_i
        @educational_performance.save

        grade_asignature = GradeAsignature.where("grade_id = ? AND educational_asignature_id = ?", params[:educational_performance][:grade_id].to_i, params[:educational_performance][:educational_asignature_id].to_i).first
        @update_performances_lists = EducationalPerformancesList.where("grade_asignature_id IS NOT NULL AND grade_asignature_id = ?", grade_asignature.id).order(:description)
        @checks_selected = params[:chk][:performance]
      end
      respond_with(@educational_performance, location: new_educational_performance_url)
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
    @educational_performance.destroy
    respond_with(@educational_performance, location: new_educational_performance_url)
  end

  def update_educational_asignature
    @update_educational_asignature = GradeAsignature.where("grade_id = ? AND school_year_id = ?", params[:gid], params[:syid])
    respond_to do |format|
      format.js
    end
  end

  def update_performances_lists
    grade_asignature = GradeAsignature.where("grade_id = ? AND educational_asignature_id = ? AND school_year_id = ?", params[:gid], params[:eaid], params[:syid]).first
    update_performances_list = EducationalPerformancesList.where("grade_asignature_id IS NOT NULL AND grade_asignature_id = ?", grade_asignature.id).order(:description)
    # if update_performances_lists.any?
      render :partial => "update_performances_lists", :locals => { :update_performances_lists => update_performances_list }
    # end
  end

  private
    def set_educational_performance
      @educational_performance = EducationalPerformance.find(params[:id])
    end

    def educational_performance_params
      params.require(:educational_performance).permit(:description,:grade_id, :educational_period_id, :educational_asignature_id, :school_year_id)
    end
end
