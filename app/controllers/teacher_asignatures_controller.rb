class TeacherAsignaturesController < ApplicationController
  load_and_authorize_resource :except => [:create]
  before_action :set_teacher_asignature, only: [:show, :destroy]

  respond_to :html

  def index
    @teacher_asignatures = TeacherAsignature.order("educational_asignature_id")
    if(current_user.role_id == 2)
      @teacher_asignatures = @teacher_asignatures.where("teacher_id=?",current_user.id)
    end
    @search = @teacher_asignatures.search(params[:q])
    @teacher_asignatures = @search.result.page(params[:page]).per(30)
    respond_with(@teacher_asignatures)
  end

  def show
    respond_with(@teacher_asignature)
  end

  def new
    @teacher_asignatures = TeacherAsignature.order("educational_asignature_id")
    if(current_user.role_id == 2)
      @teacher_asignatures = @teacher_asignatures.where("teacher_id=?",current_user.id)
    end
    @search = @teacher_asignatures.search(params[:q])
    @teacher_asignatures = @search.result.page(params[:page]).per(30)
    @update_sub_grade = SubGradeTeacher.where("id = 0")
    @update_asignatures = GradeAsignature.where("grade_id = 0").order("grade_id,internal_order")
    @teacher_asignature = TeacherAsignature.new
    respond_with(@teacher_asignature)
  end

  def update_sub_grade
    @update_sub_grade = SubGradeTeacher.where("teacher_id = ? AND school_year_id = ?", params[:tatid], get_current_school_year(Time.now.year)).order("sub_grade_id")
    respond_to do |format|
      format.js
    end
  end

  def update_asignatures
    update_asignatures = GradeAsignature.where("grade_id = ? AND school_year_id = ?",SubGradeTeacher.find(params[:taid]).sub_grade.grade_id, get_current_school_year(Time.now.year)).order("internal_order")
    render :partial => "update_asignatures", :locals => { :update_asignatures => update_asignatures }
  end

  def edit
    @update_sub_grade = SubGradeTeacher.where("teacher_id=?",set_teacher_asignature[:teacher_id]).order("sub_grade_id")
    @educational_areas = EducationalArea.where("education_level_id=?",SubGradeTeacher.where("teacher_id=?",set_teacher_asignature[:teacher_id]).map { |e| e.sub_grade.grade.education_level_id}.first)
    @update_asignatures = GradeAsignature.where("grade_id=?",set_teacher_asignature[:sub_grade_id])
    @teacher_asignatures = TeacherAsignature.order("educational_asignature_id")
    if(current_user.role_id == 2)
      @teacher_asignatures = @teacher_asignatures.where("teacher_id=?",current_user.id)
    end
    @search = @teacher_asignatures.search(params[:q])
    @teacher_asignatures = @search.result.page(params[:page]).per(30)
  end

  def create
    @teacher_asignatures = TeacherAsignature.order("educational_asignature_id")
    if(current_user.role_id == 2)
      @teacher_asignatures = @teacher_asignatures.where("teacher_id=?",current_user.id)
    end
    @search = @teacher_asignatures.search(params[:q])
    @teacher_asignatures = @search.result.page(params[:page]).per(30)
    sub_grade_teacher = SubGradeTeacher.find(teacher_asignature_params[:sub_grade_id])
    if(sub_grade_teacher)
      chk_asignature = params[:chk][:asignature]
      for i in 0...chk_asignature.size
        @find_teacher_asignatures = TeacherAsignature.where("teacher_id=? AND sub_grade_id=? AND educational_asignature_id=?",teacher_asignature_params[:teacher_id],sub_grade_teacher.sub_grade_id,chk_asignature[i])
        unless(@find_teacher_asignatures.any?)
          @teacher_asignature = TeacherAsignature.new()
          @teacher_asignature.sub_grade_teacher_id = sub_grade_teacher.id
          @teacher_asignature.teacher_id = teacher_asignature_params[:teacher_id]
          @teacher_asignature.sub_grade_id = sub_grade_teacher.sub_grade_id
          @teacher_asignature.educational_asignature_id = chk_asignature[i]
          @teacher_asignature.save
        else
          @find_teacher_asignatures.first.update_attribute(:sub_grade_teacher_id,sub_grade_teacher.id)
        end
      end
    end
    redirect_to url_for(:action => :new)
  end

  def update
    @teacher_asignatures = TeacherAsignature.order("educational_asignature_id")
    if(current_user.role_id == 2)
      @teacher_asignatures = @teacher_asignatures.where("teacher_id=?",current_user.id)
    end
    @search = @teacher_asignatures.search(params[:q])
    @teacher_asignatures = @search.result.page(params[:page]).per(30)
    str_errors=0
    str_msg = ""
    if(TeacherAsignature.where("teacher_id=? AND sub_grade_id=? AND educational_asignature_id=?",params[:teacher_asignature][:teacher_id],params[:teacher_asignature][:sub_grade_id],params[:teacher_asignature][:educational_asignature_id]).any?)
      str_msg += '<i class="fa fa-hand-o-right"></i>&nbsp;Ya se encuentra creada la asignación que esta realizando.<br>'
      str_errors +=1
    end

    if(str_errors.to_i > 0)
      flash[:error] = str_msg.to_s
      redirect_to url_for(:action => :new)
    else
      @teacher_asignature.update(teacher_asignature_params)
      respond_with(@teacher_asignature, :location => teacher_asignatures_url)
    end
  end

  def destroy
    @teacher_asignatures = TeacherAsignature.order("educational_asignature_id")
    if(current_user.role_id == 2)
      @teacher_asignatures = @teacher_asignatures.where("teacher_id=?",current_user.id)
    end
    @search = @teacher_asignatures.search(params[:q])
    @teacher_asignatures = @search.result.page(params[:page]).per(30)
    @teacher_asignature.destroy
    respond_with(@teacher_asignature, :location => new_teacher_asignature_url)
  end

  private
    def set_teacher_asignature
      @teacher_asignature = TeacherAsignature.find(params[:id])
    end

    def teacher_asignature_params
      params.require(:teacher_asignature).permit(:teacher_id, :sub_grade_id, :educational_asignature_id)
    end
end
