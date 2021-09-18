class ScoreDetailsController < ApplicationController
  load_and_authorize_resource :except => [:create,:destroy]
  before_action :set_score_detail, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @score_details = ScoreDetail.all
    respond_with(@score_details)
  end

  def show
    respond_with(@score_detail)
  end

  def new
    @score_detail = ScoreDetail.new
    @school_year_current = Time.now.year
    @school_year = SchoolYear.where("name = '?'", @school_year_current).first
    @sub_grades_teacher = SubGradeTeacher.where("teacher_id = ?", current_user.id).pluck(:sub_grade_id)
    @sub_grades = SubGrade.where("id IN (?)", @sub_grades_teacher).order(:name)
    @educational_asignatures = EducationalAsignature.where("id = 0")

    @search = ScoreDetail.search(params[:q])
    @score_details = @search.result.page(params[:page]).per(20)
    respond_with(@score_detail)
  end

  def edit
  end

  def update_asignatures
    @sub_grade_teacher = SubGradeTeacher.where("sub_grade_id = ? and teacher_id = ?", params[:sg_id], current_user)
    @teacher_asignatures = TeacherAsignature.where("sub_grade_teacher_id = ?", @sub_grade_teacher.first.id).pluck(:educational_asignature_id)
    @educational_asignatures = EducationalAsignature.where("id IN (?)", @teacher_asignatures).order(:name)#.map { |e| [e.id, e.name] }

    respond_to do |format|
      format.js
    end
  end

  def update_field_form
    @sub_grade_teacher = SubGradeTeacher.where("teacher_id = ? AND sub_grade_id = ?", current_user, params[:sub_grade_id])
    @score_details = ScoreDetail.where("school_year_id = ? AND sub_grade_teacher_id = ? AND educational_asignature_id = ? AND educational_period_id = ?", params[:year_actual], @sub_grade_teacher.last.id, params[:educational_asignature_id], params[:period_id])
    @index = 0

    if params[:flag_add_fields]
      @flag_add_fields = 1
    end

    respond_to do |format|
      format.js
    end
  end

  def update_score_detail
    #respond_with(@score_detail)
    @sub_grade_teacher_id = SubGradeTeacher.where("teacher_id = ? AND sub_grade_id = ?", current_user, params[:sub_grade_id]).last.id
    if params[:data_autosave].to_i == 1 # if 1
      params[:score_detail_id].each_with_index do |score_detail_id, index|
        if score_detail_id.to_i == 0
          @flag_update_form = 1
          @score_detail = ScoreDetail.new
        else
          @flag_update_form = 1
          @score_detail = ScoreDetail.find(score_detail_id.to_i)
        end

        @flag_repeat_name = 0
        if ScoreDetail.where("name like ?", params[:name][index]).any?
          @flag_repeat_name = 1
        end

        if params[:name][index].to_s == "" or params[:sd_detail_score_detail_id][index].blank? or params[:weight][index].blank?
        else
          @score_detail.name = params[:name][index]
          @score_detail.sd_detail_id = params[:sd_detail_score_detail_id][index]
          @score_detail.school_year_id = score_detail_params[:school_year_id]
          @score_detail.educational_period_id = score_detail_params[:educational_period_id]
          @score_detail.sub_grade_teacher_id = @sub_grade_teacher_id
          @score_detail.educational_asignature_id = score_detail_params[:educational_asignature_id]
          @score_detail.weight = params[:weight][index]
          @score_detail.description = params[:description][index] unless params[:description][index].nil?
          if @score_detail.save
            if @flag_update_form == 1
              if index == params[:score_detail_id].size - 1
                @score_details = ScoreDetail.where("school_year_id = ? AND sub_grade_teacher_id = ? AND educational_asignature_id = ? AND educational_period_id = ?", score_detail_params[:school_year_id], @sub_grade_teacher_id, score_detail_params[:educational_asignature_id], score_detail_params[:educational_period_id])

                @index = 0
                @flag_save_success = 1
                respond_to do |format|
                  format.js
                end
              end
            end
          end
        end
      end
    else # if 1
      @flag_repeat_name = 0
      params[:score_detail_id].each_with_index do |score_detail_id, index|
        if score_detail_id.to_i == 0
          @flag_update_form = 1
          @score_detail = ScoreDetail.new
        else
          @flag_update_form = 1
          @score_detail = ScoreDetail.find(score_detail_id.to_i)
        end

        if @flag_repeat_name == 0
          if ScoreDetail.where("name like ? AND id <> ?", params[:name][index], params[:score_detail_id][index]).any?
            @flag_repeat_name = 1
          end
        end

        if params[:name][index].to_s == "" or params[:sd_detail_score_detail_id][index].blank? or params[:weight][index].blank?
        else
          if @flag_repeat_name == 0
            @score_detail.name = params[:name][index]
            @score_detail.sd_detail_id = params[:sd_detail_score_detail_id][index]
            @score_detail.school_year_id = score_detail_params[:school_year_id]
            @score_detail.educational_period_id = score_detail_params[:educational_period_id]
            @score_detail.sub_grade_teacher_id = @sub_grade_teacher_id
            @score_detail.educational_asignature_id = score_detail_params[:educational_asignature_id]
            @score_detail.weight = params[:weight][index]
            @score_detail.description = params[:description][index] unless params[:description][index].nil?
            if @score_detail.save
              if @flag_update_form == 1
                if index == params[:score_detail_id].size - 1
                  @score_details = ScoreDetail.where("school_year_id = ? AND sub_grade_teacher_id = ? AND educational_asignature_id = ? AND educational_period_id = ?", score_detail_params[:school_year_id], @sub_grade_teacher_id, score_detail_params[:educational_asignature_id], score_detail_params[:educational_period_id])

                  @index = 0
                  @flag_save_success = 1
                  respond_to do |format|
                    format.js
                  end
                end
              end
            end
          end # if nombre repetido
        end #--
      end
      if @flag_repeat_name == 1
        render :js => "alert('El nombre de la actividad es igual a uno ya existente.');"
      end
      # if params[:score_detail_id].to_i == 0
      #   @flag_update_form = 1
      #   @score_detail = ScoreDetail.new
      # else
      #   @flag_update_form = 0
      #   @score_detail = ScoreDetail.find(params[:score_detail_id].to_i)
      # end
      #
      # @flag_repeat_name = 0
      # if ScoreDetail.where("name like ? AND id <> ?", params[:name], params[:score_detail_id]).any?
      #   @flag_repeat_name = 1
      # end
      #
      # if params[:name].to_s == "" or params[:sd_detail_id].blank? or params[:weight].blank?
      # else
      #   if @flag_repeat_name == 0 # if nombre repetido
      #     @score_detail.name = params[:name]
      #     @score_detail.sd_detail_id = params[:sd_detail_id]
      #     @score_detail.school_year_id = params[:school_year_id]
      #     @score_detail.educational_period_id = params[:educational_period_id]
      #     @score_detail.sub_grade_teacher_id = @sub_grade_teacher_id
      #     @score_detail.educational_asignature_id = params[:educational_asignature_id]
      #     @score_detail.weight = params[:weight]
      #     @score_detail.description = params[:description] unless params[:description].nil?
      #     if @score_detail.save
      #       if @flag_update_form == 1
      #         @score_details = ScoreDetail.where("school_year_id = ? AND sub_grade_teacher_id = ? AND educational_asignature_id = ? AND educational_period_id = ?", params[:school_year_id], @sub_grade_teacher_id, params[:educational_asignature_id], params[:educational_period_id])
      #
      #         @index = 0
      #         respond_to do |format|
      #           format.js
      #         end
      #       end
      #     end
      #   else
      #     render :js => "alert('El nombre de la actividad es igual a uno ya existente.');"
      #   end # if nombre repetido
      # end
    end # if 1
  end

  def create
    #for j in 0...params[:score_detail][:sd_detail_id].size
    #  @score_detail = ScoreDetail.new(score_detail_params)
    #  @score_detail.sd_detail_id = params[:score_detail][:sd_detail_id][j]
    #  @score_detail.weight = params[:score_detail][:weight][j]
    #  @score_detail.save
    #end
    @score_detail = ScoreDetail.new(score_detail_params)
    @score_detail.save
    respond_with(@score_detail)
  end

  def update
    @score_detail.update(score_detail_params)
    respond_with(@score_detail)
  end

  def destroy
    @score_detail.destroy
    respond_with(@score_detail)
  end

  def delete_register
    @score_detail = ScoreDetail.find(params[:score_detail_id])
    @score_detail.destroy
    respond_with(@score_detail)
  end

  private
    def set_score_detail
      @score_detail = ScoreDetail.find(params[:id])
    end

    def score_detail_params
      params.require(:score_detail).permit(:name, :sd_detail_id, :school_year_id, :educational_period_id, :sub_grade_teacher_id, :educational_asignature_id, :weight, :description)
    end
end
