class FinalValueRecordsController < ApplicationController
  before_action :set_final_value_record, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    @final_value_records = FinalValueRecord.where("id = 0")
    @school_year_current = Time.now.year
    # @school_year_current = 2018
    @school_years = SchoolYear.order(:id)
    @school_year = SchoolYear.where("name = '?'", @school_year_current).first
    if params[:school_year_chosen].present?
      @sub_grades_year_current = SubGradeTeacher.where("school_year_id = ?", params[:school_year_chosen]).pluck(:sub_grade_id)
    else
      @sub_grades_year_current = SubGradeTeacher.where("school_year_id = ?", get_current_school_year(@school_year_current)).pluck(:sub_grade_id)
    end
    @sub_grades = SubGrade.where("id IN (?)", @sub_grades_year_current).order(:ordering)

    if params[:commit] == 'filter'
      @final_value_records = FinalValueRecord.all
      @sub_grade_id = params[:sub_grade_id]
      @users = User.where("status = 1")
      @student_sub_grades = StudentSubGrade.where("student_id IN (?) AND sub_grade_id = ? AND school_year_id = ?", @users.pluck(:id), @sub_grade_id, params[:school_year_id])

      unless false #@final_value_records.where("student_sub_grade_id IN (?)", @student_sub_grades.pluck(:id)).any?
        @student_progresses = StudentProgress.includes(:grade_asignature).where("student_sub_grade_id IN (?)", @student_sub_grades.pluck(:id))
        if @student_progresses.any?
          @student_progresses.order(:student_sub_grade_id, 'grade_asignatures.internal_order').each do |student_progress|
            educational_area_id = student_progress.educational_asignature.educational_area_id

            educational_asignatures = EducationalAsignature.where("educational_area_id = ?", educational_area_id)
            @student_progresses_tmp = @student_progresses.where("student_sub_grade_id = ? AND student_progresses.educational_asignature_id IN (?)", student_progress.student_sub_grade_id, educational_asignatures.pluck(:id))

            educational_asignatures_tmp = EducationalAsignature.where

            sum_score = 0.0
            str_name_asignatures = ""
            educational_asignatures.each_with_index do |educational_asignature, index|
              sum_score += sprintf("%.1f", @student_progresses_tmp.where("student_progresses.educational_asignature_id = ?", educational_asignature.id).average(:score)).to_f unless @student_progresses_tmp.where("student_progresses.educational_asignature_id = ?", educational_asignature.id).blank?
              str_name_asignatures += educational_asignature.name
              str_name_asignatures += " - " unless educational_asignatures.size - 1 == index
            end
            count_records = @student_progresses_tmp.group(:educational_asignature_id).length
            average_total_score = sum_score / count_records
            final_value_records_tmp = FinalValueRecord.where("student_sub_grade_id = ? AND educational_area_id = ?", student_progress.student_sub_grade_id, educational_area_id)
            if final_value_records_tmp.any?
              final_value_record = final_value_records_tmp.first
            else
              final_value_record = FinalValueRecord.new
            end
            final_value_record.student_sub_grade_id = student_progress.student_sub_grade_id
            final_value_record.educational_area_id = educational_area_id
            final_value_record.educational_asignatures_name = str_name_asignatures
            final_value_record.average_total_score = sprintf("%.1f", average_total_score)
            final_value_record.save
          end
        end
      end
      @search = FinalValueRecord.where("student_sub_grade_id IN (?)", @student_sub_grades.pluck(:id)).search(params[:q])
      @final_value_records = @search.result.page(params[:page]).per(3000)
    end
    respond_with(@final_value_records)
  end

  def save_recovered
    count_score_success = 0
    msg = ""
    params[:array_score].each do |key, value|
      unless value.empty?
        final_value_record = FinalValueRecord.find(key)
        final_value_record.recovered_score = value
        if final_value_record.save
          if count_score_success > 1
            msg = "Se han guardado las notas"
          else
            msg = "Se ha guardado la nota"
          end
          count_score_success += 1
        end
      end
    end
    if msg.empty?
      redirect_to :back
    else
      redirect_to :back, notice: msg
    end
  end

  def show
    respond_with(@final_value_record)
  end

  def new
    @final_value_record = FinalValueRecord.new
    respond_with(@final_value_record)
  end

  def edit
  end

  def create
    @final_value_record = FinalValueRecord.new(final_value_record_params)
    @final_value_record.save
    respond_with(@final_value_record)
  end

  def update
    @final_value_record.update(final_value_record_params)
    respond_with(@final_value_record)
  end

  def destroy
    @final_value_record.destroy
    respond_with(@final_value_record)
  end

  private
    def set_final_value_record
      @final_value_record = FinalValueRecord.find(params[:id])
    end

    def final_value_record_params
      params.require(:final_value_record).permit(:student_sub_grade_id, :educational_area_id, :average_total_score, :recovered_score)
    end
end
