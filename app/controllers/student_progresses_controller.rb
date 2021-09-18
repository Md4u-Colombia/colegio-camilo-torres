class StudentProgressesController < ApplicationController
  load_and_authorize_resource :except => [:create,:generate_pdf]
  before_action :set_student_progress, only: [:show, :edit, :update, :destroy]

  respond_to :html

  def index
    #@student_progresses = StudentProgress.all
    @student_progresses = StudentProgress.order("student_sub_grade_id desc").page(params[:page]).per(1500)
    respond_with(@student_progresses)
  end

  def show
    respond_with(@student_progress)
  end

  def save_data
    @student_progress = StudentProgress.find(params[:student_progress_id])
    @student_progress.score = params[:score]
    @student_progress.log = "Ingreso de calificación por corrección realizada por #{current_user.complete_name} / #{Time.now.strftime("%Y-%m-%d")}: calificación:  #{params[:score]}"
    @student_progress.save
  end

  def new
    @student_progress = StudentProgress.new
    @student_progresses = StudentProgress.all

    @school_year_current = Time.now.year
    @school_year = SchoolYear.where("name = '?'", @school_year_current).first
    @educational_asignatures = EducationalAsignature.where("id = 0")

     # OBTENER EL PERIODO ACTUAL Y EL SELECT AUTOMÁTICO DEL PERIODO
    @educational_period_id_range = get_current_period()
    educational_period = EducationalPeriod.find(@educational_period_id_range)
    @educational_periods = EducationalPeriod.where("internal_order <= ?", educational_period.internal_order).order(:internal_order)
    #@sub_grades_teacher = SubGradeTeacher.where("teacher_id = ? AND school_year_id = ?", current_user.id, get_current_school_year(@school_year_current)).pluck(:sub_grade_id)
    @sub_grades = SubGrade.order(:id)
    @students = User.where("id = 0")

    if params[:commit] == "filter"
      school_year_id = params[:school_year_id]
      @sub_grade_id = params[:sub_grade_id]
      grade_id = SubGrade.find(@sub_grade_id).grade_id
      @period_id = params[:educational_period_id]
      @educational_period_id_range = @period_id

      # SE OBTIENEN LOS ALUMNOS
      @students_grades = StudentsGrade.where("school_year_id = ? AND grade_id = ?", school_year_id, grade_id)
      @student_sub_grades = StudentSubGrade.where("students_grade_id IN (?) AND sub_grade_id = ?", @students_grades.pluck(:id), @sub_grade_id)
      @student_sub_grades_tmp = StudentSubGrade.where("sub_grade_id = ? AND school_year_id = ?", @sub_grade_id, school_year_id)
      @students = User.order(:last_name).where("id IN (?)", @student_sub_grades.pluck(:student_id))

      @sub_grade_teachers = SubGradeTeacher.where("sub_grade_id = ? AND school_year_id = ?", @sub_grade_id, school_year_id)
      @teacher_asignatures = TeacherAsignature.where("sub_grade_teacher_id IN (?)", @sub_grade_teachers.pluck(:id)).pluck(:educational_asignature_id)
      @educational_asignatures = EducationalAsignature.where("id IN (?)", @teacher_asignatures).order(:name)#.map { |e| [e.id, e.name] }

      grade_asignatures = GradeAsignature.where("educational_asignature_id IN (?) AND grade_id = ? AND school_year_id = ? AND status = 1", @educational_asignatures.pluck(:id), grade_id, school_year_id)
      @educational_asignatures_ids = grade_asignatures.order(:internal_order).pluck(:educational_asignature_id)
      @educational_asignatures = EducationalAsignature.where("id IN (?)", @educational_asignatures_ids)
      @educational_areas = EducationalArea.order(:id)
    end

    respond_with(@student_progress)
  end

  def edit
    @student_progresses = StudentProgress.all
  end

  def create
    @student_progress = StudentProgress.new(student_progress_params)
    @student_progress.save
    respond_with(@student_progress, location: new_student_progress_url)
  end

  def update
    @student_progress.update(student_progress_params)
    #respond_with(@student_progress, location: new_student_progress_url)
    respond_with(@student_progress, location: student_progresses_url)
  end

  def destroy
    @student_progress.destroy
    respond_with(@student_progress, location: new_student_progress_url)
  end

  def upercase(str)
    return str.mb_chars.upcase
  end

  def generate_pdf
    #require 'prawn'

    session_file = "public/pdfs"

    params[:period_id] = params[:peid]
    params[:student_sub_grade_id] = params[:ssg_id]

    # Obtener el año escolar
    @school_year = SchoolYear.find(params[:sy_id])
    # Obtener datos de tabla de progreso del studiante student_progresses
    @student_progresses = StudentProgress.includes(:grade_asignature).order('grade_asignatures.internal_order').where("student_sub_grade_id = ?", params[:student_sub_grade_id])
    # Obtener los comentarios
    @student_comments = StudentComment.where("student_sub_grade_id = ?", params[:student_sub_grade_id])

    @student_sub_grade = StudentSubGrade.find(params[:student_sub_grade_id])

    @periods = EducationalPeriod.find(params[:period_id])
    @last_internal_order = @periods.internal_order

    @subgrade = SubGrade.find(@student_sub_grade.sub_grade_id)

    @grade = Grade.find(@subgrade.grade_id)

    @educationLevel = EducationLevel.find(@grade.education_level_id)

    str_student_name = "#{User.find(@student_sub_grade.student_id).complete_name.mb_chars.upcase}"
    str_sub_grade = "#{upercase(@subgrade.name)}"

    Prawn::Document.generate("#{Rails.root}/#{session_file}/#{t('.boletin')}_.pdf", :page_size => [215, 330], :page_layout => :landscape, :margin => [5, 5, 5, 5], :background => "#{Rails.root}/public/images/boletin/log_marca_agua.jpg") do |pdf|

    #Prawn::Document.generate("#{Rails.root}/#{session_file}/#{t('.boletin')}_.pdf", :page_size => [215, 330], :page_layout => :landscape, :margin => [5, 5, 5, 5]) do |pdf|

      pdf.move_down 2

      tam_str_header = 4
      tam_str_table = 3.2
      image_header = "#{Rails.root}/public/images/boletin/logo.jpg"
      image_water_mark = "#{Rails.root}/public/images/boletin/log_marca_agua.jpg"

      # Hacer una tabla para esto que se llame education_level_resolutions
      if @educationLevel.id == 1  #si es preescolar
        str_header = "<b>#{t('.title_boletin')}</b><br>RES: 000830 Del 27 de Septiembre de 1.999<br><b>#{t('.boletin_report')}</b>"
      elsif @educationLevel.id == 2 #si es primaria
        str_header = "<b>#{t('.title_boletin')}</b><br>RESOLUCIÓN: 004639 Del 21 de Noviembre de 2013<br><b>#{t('.boletin_report')}</b>"
      else #si es bachillerato
        str_header = "<b>#{t('.title_boletin')}</b><br>E-285 Del 30 de Diciembre de 2011 - 629 del 30 de Junio del 2015<br><b>#{t('.boletin_report')}</b>"
      end
      str_header_2 = "<b>#{t('.period')}:</b> #{EducationalPeriod.find(params[:period_id]).name.upcase}"
      str_header_3 = "<b>#{t('.date')}:</b> #{@periods.month_report.upcase} DE #{@school_year.name}"
      str_header_4 = "<b>#{t('.student_name')}:</b> #{str_student_name}"
      str_header_5 = "<b>#{t('.grade')}:</b> #{str_sub_grade}"
      if @educationLevel.id != 1
        str_header_6 = "<b>#{t('.rating')}:</b>    #{t('.rating_excelent_super')}    #{t('.rating_outstanding_super')}    #{t('.rating_acceptable_super')}    #{t('.rating_insufficient_super')}"
      else
        str_header_6 = "<b>#{t('.rating')}:</b>    #{t('.rating_excelent')}    #{t('.rating_outstanding')}    #{t('.rating_acceptable')}    #{t('.rating_insufficient')}"
      end

      array_str_header_6 = Array.new
      str_header_6_tmp = ""
      str_header_6.split(//).each_with_index do |character, index|
        if character.to_s >= "0" and character <= "9".to_s
          array_str_header_6[index] = "<b>#{character}</b>"
        else
          array_str_header_6[index] = character
        end
        str_header_6_tmp += array_str_header_6[index]
        #pdf.text "str_header_6_tmp: #{str_header_6_tmp}<br>", :inline_format => true
      end

      str_header_6 = str_header_6_tmp

      #pdf.text str_header_6

      tam_str_header_table = 2.5

      # SE REALIZA ESTE CONDICIONAL PARA CAMBIAR EL HEADER DE LA TABLA DEL BOLETIN
      if @educationLevel.id == 1 # SI EL NIVEL EDUCATIVO ES PRE-ESCOLAR
        str_area_header       = "DIMENSIONES"
        str_asignature_header = "PROCESOS DE DESARROLLO"
      else
        str_area_header       = "AREA"
        str_asignature_header = "ASIGNATURA"
      end

      #array_table_boletin = Array.new(4) { Array.new(20) }

      array_table_boletin = [
          [
            {
              :content => "<b>#{str_area_header}</b>",
              :align => :center,
              :valign => :center,
              :size => tam_str_header_table,
              :height => 10,
              :padding => [0, 2, 5, 2],
              :background_color => "E0E0E0",
              :width => 40
            },

            {
              :content => "<b>#{str_asignature_header}</b>",
              :align => :center,
              :valign => :center,
              :size => tam_str_header_table,
              :height => 10,
              :padding => [0, 2, 5, 2],
              :background_color => "E0E0E0",
              :width => 40
            }
          ]
        ]

      # SE CREAN LOS CAMPOS DE NOTA POR PERIODO Y DEFINITIVA EN EL HEADER
      for i in 1..@periods.internal_order

        array_table_boletin[0] <<
          {
            :content => "<b>PERIODO<br>#{i}</b>",
            :size => (tam_str_header_table - 0.65),
            :height => 10,
            :align => :center,
            :valign => :center,
            :width => 12 ,
            :background_color => "E0E0E0",
            :padding => [0, 2, 3, 2]
          }

        if i == 4
          array_table_boletin[0] <<
          {
            :content => "<b>DEFINITIVA</b>",
            :size => (tam_str_header_table - 0.9),
            :height => 10,
            :align => :center,
            :valign => :center,
            :width => 12 ,
            :background_color => "E0E0E0",
            :padding => [0, 2, 5, 2]
          }
        end
      end

      if i < 4
        array_table_boletin[0] <<
        {
          :content => "<b>PROM</b>",
          :size => (tam_str_header_table - 0.9),
          :height => 10,
          :align => :center,
          :valign => :center,
          :width => 12 ,
          :background_color => "E0E0E0",
          :padding => [0, 2, 5, 2]
        }
      end

      # SE ASIGNA AL HEADER EL CAMPO DE DESEMPEÑO
      array_table_boletin[0] <<

          {
            :content => "<b>DESEMPEÑOS</b>",
            :align => :center,
            :valign => :center,
            :size => tam_str_header_table + 1,
            :height => 10,
            :background_color => "E0E0E0",
            :padding => [0, 2, 5, 2]
            #:width => 160
          }

      # PROCESAR DATOS
      array_asignatures = Array.new
      array_areas = Array.new
      array_areas_tmp = Array.new
      width = @student_progresses.where("period_id = ?", params[:period_id].to_i).size
      height = params[:period_id].to_i
      array_score_periodos = Array.new(width) { Array.new(height) }
      array_performances = Array.new

      for i in 1..@periods.internal_order
        if @student_progresses.where("student_progresses.period_id = ?", i).any?
          @student_progresses.where("student_progresses.period_id = ?", i).each_with_index do |student_progress, index|

          	# if student_progress.educational_asignature.status.to_i == 1
	            if student_progress.period.internal_order == @periods.internal_order
	              array_asignatures[index] = student_progress.educational_asignature_id
	              array_areas[index] = EducationalAsignature.find(array_asignatures[index]).educational_area_id
	              array_areas_tmp << array_areas[index]
	            end

	            array_score_periodos[index][i - 1] = student_progress.score.to_f

	            if student_progress.period.internal_order.to_i == @last_internal_order.to_i
	              array_performances[index] = EducationalPerformance.find(student_progress.educational_performance_id).description
	            end
	          # end
          end
        else
          @student_progresses.where("student_progresses.period_id = ?", @periods.id).each_with_index do |student, index|
            array_score_periodos[index][i - 1] = student.score.to_f
          end
        end
      end
      # ==================================================
      # SE GENERAN LOS CAMPOS DE AREA ASIGNATURA Y DEMÁS
      # ==================================================
      tam_text_table = 2.8
      flag_asignature = false
      #puts "??????????????#{array_areas_tmp}"
      array_asignatures.each_with_index do |array_asignature, index|
        count_areas = array_areas.count(array_areas[index])
        count_areas = 1

        if flag_asignature == false
          count_index = 0
          array_areas_tmp.each do |area|
            if array_areas_tmp[count_index] == array_areas_tmp[count_index + 1]
              count_areas += 1
            else
              array_areas_tmp.shift
              break
            end
            array_areas_tmp.shift
            count_index = 0
            #puts ".......................#{array_areas_tmp}"
          end
        end
        # puts "index: #{index}"
        # puts "count_areas: #{count_areas}"
        array_table_boletin[index + 1] = []
        if flag_asignature == false
          array_table_boletin[index + 1] <<

            {
              :content => "<b>#{EducationalArea.find(array_areas[index]).name.mb_chars.upcase}</b>",
              :align => :center,
              :valign => :center,
              :size => tam_text_table,
              :rowspan => count_areas,
              :padding => [0, 2, 5, 2],
              :width => 40
            }

          flag_asignature = true
          puts array_table_boletin[index + 1]
        end
        array_table_boletin[index + 1] <<
        {
          :content => "<b>#{EducationalAsignature.find(array_asignatures[index]).name.mb_chars.upcase}</b>",
          :align => :center,
          :valign => :center,
          :size => tam_text_table,
          :padding => [0, 2, 5, 2],
          :width => 40
        }

        # Se imprime el score por periodos
        for i in 1..@periods.internal_order
          array_table_boletin[index + 1] <<
          {
            :content => "#{array_score_periodos[index][i - 1]}",
            :align => :center,
            :valign => :center,
            :size => tam_text_table,
            :padding => [0, 2, 5, 2],
            :width => 12
          }
        end

        if i <= 4
          array_table_boletin[index + 1] <<
          {
            :content => "#{sprintf("%.1f", array_score_periodos[index].inject{ |sum, el| sum + el }.to_f / array_score_periodos[index].size)}",
            :align => :center,
            :valign => :center,
            :size => tam_text_table,
            :padding => [0, 2, 5, 2],
            :width => 12
          }
        end

        array_performances_tmp = array_performances[index].split(";")
        str_performances = ""
        array_performances_tmp.each do |performance|
          str_performances = str_performances << "\u2022 #{performance}<br>"
        end

        if @grade.id == 12 or @grade.id == 13
          tam_text_table_tmp = tam_text_table + 0.3
        else
          tam_text_table_tmp = tam_text_table + 1
        end

        array_table_boletin[index + 1] <<
        {
          :content => "#{str_performances}",
          :align => :left,
          :valign => :center,
          :size => tam_text_table_tmp,
          :padding => [-2, 7, 5, 7]
        }
        #puts array_areas
        #puts "array_areas[index]: #{array_areas[index]} != array_areas[index + 1]: #{array_areas[index + 1]}"
        if array_areas[index].to_i != array_areas[index + 1].to_i
          flag_asignature = false
          #break
        end
      end
      # ==================================================

      # puts "********************#{array_table_boletin}"

      tam_general_table = 315 # TAMAÑO GENERAL DE LA TABLA

      pdf.table(
        [
          [
            {
              :content => str_header,
              :align => :center,
              :size => tam_str_header,
              :colspan => 2,
              :height => 20,
              :width => 250
            },

            {
              :image => image_header,
              :scale => 0.3,
              :rowspan => 4,
              :position => :center,
              :vposition => :center,
              :width => tam_general_table - 250
            }
          ],

          [
            {
              :content => str_header_2,
              :size => tam_str_table,
              :padding => 0
            },

            {
              :content => str_header_3,
              :size => tam_str_table,
              :padding => 0
            }
          ],

          [
            {
              :content => str_header_4,
              :size => tam_str_table
            },

            {
              :content => str_header_5,
              :size => tam_str_table
            }
          ],

          [
            {
              :content => str_header_6,
              :colspan => 2,
              :size => tam_str_table
            }
          ]

        ],
        :cell_style => {
          :borders => [],
          :border_width => 0.1,
          :inline_format => true,
          :padding => 0
        }, :width => tam_general_table, :position => :center)

        # ==================================================
        # SE GENERA LA TABLA DEL BOLETIN
        # ==================================================
        pdf.move_down 2

        pdf.table(
          array_table_boletin,
          :cell_style => {
          :borders => [:left, :right, :top, :bottom],
          :border_width => 0.1,
          :inline_format => true
        }, :width => tam_general_table, :position => :center, :header => true)

        pdf.move_down 5

        @student_comments.where("educational_period_id = ?", params[:period_id]).each do |student_comment|
          # if student_progress.comments.delete(' ').to_s != ""
            @comments = student_comment.comments
          # end
        end
        pdf.table(
          [
            [
              {
                :content => "<b>OBSERVACIONES</b>",
                :colspan => 3,
                :padding => [1, 2, 1, 2],
                :size => tam_str_table
              }
            ],
            [
              {
                :content => @comments.to_s,
                :colspan => 3,
                :padding => [1, 2, 5, 2],
                :size => tam_str_table
              }
            ],
            [
              {
                :content => "<b>ACUDIENTE</b>",
                :padding => [1, 2, 1, 2],
                :size => tam_str_table,
                :width => 105
              },
              {
                :content => "<b>DIRECTOR DE GRUPO</b>",
                :padding => [1, 2, 1, 2],
                :size => tam_str_table,
                :width => 105
              },
              {
                :content => "<b>RECTORA</b>",
                :padding => [1, 2, 1, 2],
                :size => tam_str_table,
                :width => 105
              }
            ],
            [
              {
                :content => "",
                :padding => [1, 2, 1, 2],
                :size => tam_str_table
              },
              {
                :content => User.find(@subgrade.course_director_id).complete_name.mb_chars.upcase.to_s,
                :padding => [1, 2, 1, 2],
                :size => tam_str_table
              },
              {
                :content => "GLORIA DEL PILAR NIÑO",
                :padding => [1, 2, 1, 2],
                :size => tam_str_table
              }
            ]

          ],
          :cell_style => {
            :borders => [],
            :border_width => 0.1,
            :inline_format => true
          }, :width => tam_general_table, :position => :center)
        # ==================================================
        # pdf.page_count.times do |i|
        #   pdf.go_to_page i
        #   #pdf.image "image.jpg", :at => [pdf.bounds.right - 100, 0], # :align => :right
        #   pdf.image image_water_mark, :at => [115, 130], :width => 100
        # end
    end

    archive = File.join(Rails.root,session_file,"#{t('.boletin')}_")+'.pdf'
    t = Time.now
    date_ready = t.strftime("%d-%m-%Y")
    send_file archive, :filename => "PERIODO_#{@periods.name.upcase}_#{str_sub_grade}_#{str_student_name.gsub(" ","_")}_#{t('.boletin').upcase}_#{date_ready}.pdf", :type => "application/pdf"
    FileUtils.rm_rf(Dir.glob(session_file + '/' + "#{str_sub_grade}_#{str_student_name.gsub(" ","_")}_#{t('.boletin').upcase}_#{date_ready}" + ".pdf"))
  end

  def set_position_student_sub_grade(student_sub_grades, educational_period_id)
    # Llenará la table de average_student_sub_grade quien determinará el puesto del estudiante en el curso
    Rails.logger.info "*********ingresa a set_position_student_sub_grade"
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

  private
    def set_student_progress
      @student_progress = StudentProgress.find(params[:id])
    end

    def student_progress_params
      params.require(:student_progress).permit(:student_sub_grade_id,:grade_asignature_id, :educational_asignature_id, :educational_performance_id, :period_id, :score,:comments)
    end
end
