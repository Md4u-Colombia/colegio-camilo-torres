class ExportPdfController < ApplicationController
  def student_report_individual
    session_file = "public/pdfs"

    params[:period_id] = params[:peid]
    params[:student_sub_grade_id] = params[:ssg_id]

    # Obtener el año escolar
    @school_year = SchoolYear.find(params[:sy_id])
    # Obtener datos de tabla de progreso del estudiante student_progresses
    @student_progresses = StudentProgress.includes(:grade_asignature).order('grade_asignatures.internal_order').where("student_sub_grade_id = ? AND school_year_id = ?", params[:student_sub_grade_id], @school_year.id)

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
        str_header_6 = "<b>#{t('.rating')}:</b>    #{t('.rating_excelent_super')}    #{t('.rating_outstanding_super')}    #{t('.rating_acceptable_super')}    #{t('.rating_insufficient_super')}    <b>PUESTO ALUMNO:</b>  #{AverageStudentSubGrade.where('student_sub_grade_id = ? AND educational_period_id = ?', @student_sub_grade.id, params[:period_id]).first.place}"
      else
        str_header_6 = "<b>#{t('.rating')}:</b>    #{t('.rating_excelent')}    #{t('.rating_outstanding')}    #{t('.rating_acceptable')}    #{t('.rating_insufficient')}    <b>PUESTO ALUMNO:</b>  #{AverageStudentSubGrade.where('student_sub_grade_id = ? AND educational_period_id = ?', @student_sub_grade.id, params[:period_id]).first.place}"
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
                str_performances_tmp = EducationalPerformanceGrade.where("grade_asignature_id = ? AND educational_period_id = ? AND educational_performances_list_id <> 1", student_progress.grade_asignature_id, student_progress.period_id).map { |e| e.educational_performances_list.description }

                 array_performances[index] = str_performances_tmp.join(";")
                 puts "**************array_performances[index]: #{array_performances[index]}"
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

        pdf.move_down 2

        @student_comments.where("educational_period_id = ?", params[:period_id]).each do |student_comment|
          # if student_progress.comments.delete(' ').to_s != ""
            @comments = student_comment.comments
            # puts "-***--**-*/#{@comments.to_s}"
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
                :padding => [1, 2, 2, 2],
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

  def final_value_record_pdf
    session_file = "public/pdfs"

    params[:period_id] = params[:peid]
    params[:student_sub_grade_id] = params[:ssg_id]

    # Obtener el año escolar
    @school_year = SchoolYear.find(params[:sy_id])
    # Obtener datos de tabla de progreso del estudiante student_progresses
    @student_progresses = StudentProgress.includes(:grade_asignature).order('grade_asignatures.internal_order').where("student_sub_grade_id = ? AND school_year_id = ?", params[:student_sub_grade_id], @school_year.id)

    # Obtener los comentarios
    @student_comments = StudentComment.where("student_sub_grade_id = ?", params[:student_sub_grade_id])

    @student_sub_grade = StudentSubGrade.find(params[:student_sub_grade_id])

    @final_value_records = FinalValueRecord.where("student_sub_grade_id = ?", params[:student_sub_grade_id])

    @periods = EducationalPeriod.find(params[:period_id])
    @last_internal_order = @periods.internal_order

    @subgrade = SubGrade.find(@student_sub_grade.sub_grade_id)

    @grade = Grade.find(@subgrade.grade_id)

    @educationLevel = EducationLevel.find(@grade.education_level_id)

    str_student_name = "#{User.find(@student_sub_grade.student_id).complete_name.mb_chars.upcase}"
    str_sub_grade = "#{upercase(@subgrade.name)}"
    str_grade = "#{upercase(@grade.name)}"
    str_school_year = "#{upercase(@school_year.name)}"

    Prawn::Document.generate("#{Rails.root}/#{session_file}/#{t('.boletin')}_.pdf", :margin => [30, 40, 30, 40]) do |pdf|

      # #Prawn::Document.generate("#{Rails.root}/#{session_file}/#{t('.boletin')}_.pdf", :page_size => [215, 330], :page_layout => :landscape, :margin => [5, 5, 5, 5]) do |pdf|

      # pdf.move_down 2

      tam_str_header = 4
      tam_str_table = 3.2
      image_header = "#{Rails.root}/public/images/boletin/logo.png"
      # image_water_mark = "#{Rails.root}/public/images/boletin/log_marca_agua.jpg"

      # # Hacer una tabla para esto que se llame education_level_resolutions
      # if @educationLevel.id == 1  #si es preescolar
      str_header_title = "<b>#{t('.title_boletin').split(" - ")[0]}</b><br><b>#{t('.title_boletin').split(" - ")[1]}</b>"
      str_header = "RES PRE-ESCOLAR: 000830 Del 27 de Septiembre de 1.999<br>RES BASICA PRIMARIA: 004639 Del 21 de Noviembre de 2013<br>RES BASICA SECUNDARIA: E-285 Del 30 de Diciembre de 2011<br>629 del 30 de Junio del 2015<br>NID: 325899001601<br>CRA 19 No. 15 - 45 | TEL 8515702"
      str_header_subtitle = "<b>LA SUSCRITA RECTORA DE LA INSTITUCION EDUCATIVA<br>CAMILO TORRES - ZIPAQUIRA </b><br>"
      str_header_certifies = "<b>CERTIFICA</b>"
      # elsif @educationLevel.id == 2 #si es primaria
      #   str_header = "<b>#{t('.title_boletin')}</b><br>RESOLUCIÓN: 004639 Del 21 de Noviembre de 2013<br><b>#{t('.boletin_report')}</b>"
      # else #si es bachillerato
      #   str_header = "<b>#{t('.title_boletin')}</b><br>E-285 Del 30 de Diciembre de 2011 - 629 del 30 de Junio del 2015<br><b>#{t('.boletin_report')}</b>"
      # end
      str_header_2 = "<b>#{t('.period')}:</b> #{EducationalPeriod.find(params[:period_id]).name.upcase}"
      str_header_3 = "<b>#{t('.date')}:</b> #{@periods.month_report.upcase} DE #{@school_year.name}"
      str_header_4 = "<b>#{t('.student_name')}:</b> #{str_student_name}"
      str_header_5 = "<b>#{t('.grade')}:</b> #{str_sub_grade}"

      tam_str_header_table = 8

      # SE REALIZA ESTE CONDICIONAL PARA CAMBIAR EL HEADER DE LA TABLA DEL BOLETIN
      if @educationLevel.id == 1 # SI EL NIVEL EDUCATIVO ES PRE-ESCOLAR
        str_area_header       = "DIMENSIONES"
        str_asignature_header = "PROCESOS DE DESARROLLO"
      else
        str_area_header       = "AREAS FUNDAMENTALES"
        str_asignature_header = "ASIGNATURA"
      end

      #array_table_boletin = Array.new(4) { Array.new(20) }

      array_table_boletin = [
          [
            {
              :content => "<b>#{str_area_header}</b>",
              :align => :center,
              :valign => :center,
              :size => (tam_str_header_table - 1),
              :height => 10,
              :padding => [-2, 2, 2, 2],
              :background_color => "E0E0E0",
              :width => 150
            },

            {
              :content => "<b>#{str_asignature_header}</b>",
              :align => :center,
              :valign => :center,
              :size => (tam_str_header_table - 1),
              :height => 25,
              :padding => [-2, 2, 2, 2],
              :background_color => "E0E0E0",
              :width => 170
            },

            {
              :content => "<b>ESCALA NACIONAL</b>",
              :align => :center,
              :valign => :center,
              :size => (tam_str_header_table - 1),
              :height => 25,
              :padding => [-2, 2, 2, 2],
              :background_color => "E0E0E0",
              :width => 110
            },

            {
              :content => "<b>ESCALA NUMÉRICA</b>",
              :align => :center,
              :valign => :center,
              :size => (tam_str_header_table - 1),
              :height => 25,
              :padding => [-2, 2, 2, 2],
              :background_color => "E0E0E0",
              :width => 100
            }

          ]
        ]

      # SE CREAN LOS CAMPOS DE NOTA DEFINITIVA POR AREA
      @final_value_records.each_with_index do |final_value_record, index|

        average_total_score = final_value_record.recovered_score.blank? ? final_value_record.average_total_score.to_s.gsub(".", "") : final_value_record.recovered_score.to_s.gsub(".", "")

        array_table_boletin << [
          {
            :content => "#{upercase(final_value_record.educational_area.name)}",
            :size => (tam_str_header_table - 1),
            :align => :center,
            :valign => :center,
            :width => 12 ,
            :padding => [0, 2, 6, 2]
          },

          {
            :content => "#{upercase(final_value_record.educational_asignatures_name)}",
            :size => (tam_str_header_table - 1),
            :align => :center,
            :valign => :center,
            :width => 12 ,
            :padding => [0, 2, 6, 2]
          },

          {
            :content => nationalScore(final_value_record.average_total_score).to_s,
            :size => (tam_str_header_table - 1),
            :align => :center,
            :valign => :center,
            :width => 12 ,
            :padding => [0, 2, 6, 2]
          },

          {
            :content => "<b>#{average_total_score}</b>",
            :size => (tam_str_header_table - 1),
            :height => 10,
            :align => :center,
            :valign => :center,
            :width => 12 ,
            :padding => [0, 2, 6, 2]
          }
        ]
      end

      pdf.repeat :all do
        # header
        pdf.bounding_box [pdf.bounds.left, pdf.bounds.top], :width  => pdf.bounds.width do
            pdf.table(
              [
                [
                  {
                    :image => image_header,
                    :scale => 0.7,
                    :rowspan => 4,
                    :position => :center,
                    :vposition => :center,
                    :width => 100
                  },

                  {
                    :content => str_header_title,
                    :align => :center,
                    :size => 10,
                  },

                ],

                [
                  {
                    :content => str_header,
                    :align => :center,
                    :size => 8,
                    #:height => 30,
                    :width => 300
                  }
                ],

                [
                  {
                    :content => str_header_subtitle,
                    :align => :center,
                    :valign => :center,
                    :size => 8,
                    :height => 40,
                    :width => 300
                  }
                ],

                [
                  {
                    :content => str_header_certifies,
                    :align => :center,
                    :valign => :center,
                    :size => 10,
                    :height => 30
                    #:width => 300
                  }
                ]
              ],
              :cell_style => {
                :borders => [],
                :border_width => 0.1,
                :inline_format => true,
                :padding => 0
              }, :position => :center)

        end

        # footer
        pdf.bounding_box [pdf.bounds.left, pdf.bounds.bottom + 16], :width  => pdf.bounds.width do
            pdf.move_down 5
            pdf.font("#{Rails.root}/public/font/LCALLIG.TTF") do
              pdf.text "Eduquemos a los niños y jóvenes para formar hombres creadores de ideas y protagonistas de nuestra sociedad", :size => 9, inline_format: :true, align: :center
            end
        end
      end

      pdf.bounding_box([pdf.bounds.left, pdf.bounds.top - 160], :width  => pdf.bounds.width, :height => pdf.bounds.height - 100) do

        flag_is_approved = false
        count_course_not_approved = 0
        @final_value_records.each do |final_value_record|
          count_course_not_approved = @final_value_records.where("student_sub_grade_id = ? AND FORMAT(average_total_score, 1) < FORMAT(3.3, 1)", final_value_record.student_sub_grade_id).size
          with_label = "31"
          if count_course_not_approved > 2
            flag_is_approved = true
          else
            if count_course_not_approved == @final_value_records.where("student_sub_grade_id = ? AND FORMAT(average_total_score, 1) < FORMAT(3.3, 1) AND FORMAT(recovered_score, 1) >= FORMAT(3.3, 1)", final_value_record.student_sub_grade_id).size
              flag_is_approved = false
            else
              if @final_value_records.where("student_sub_grade_id = ? AND FORMAT(average_total_score, 1) < FORMAT(3.3, 1) AND (recovered_score IS NULL)", final_value_record.student_sub_grade_id).size > 0
                flag_is_approved = true
              else
                if @final_value_records.where("student_sub_grade_id = ? AND FORMAT(average_total_score, 1) < FORMAT(3.3, 1) AND FORMAT(recovered_score, 1) < FORMAT(3.3, 1)", final_value_record.student_sub_grade_id).size > 0
                  flag_is_approved = true
                end
              end
            end
          end
        end

        is_approved = "aprobó"
        is_approved = "no aprobó" if flag_is_approved
        pdf.text "Que <b>#{str_student_name}</b> cursó y #{is_approved} el grado <b>#{str_grade}</b> de educación <b>#{upercase(@grade.education_level.name)}</b> durante el año #{str_school_year}, con la siguiente valoración académica final:", inline_format: true, size: 10

        # ==================================================
        # SE GENERA LA TABLA DEL BOLETIN
        # ==================================================
        pdf.move_down 10

        pdf.table(
          array_table_boletin,
          :cell_style => {
          :borders => [:left, :right, :top, :bottom],
          :border_width => 0.1,
          :inline_format => true
        },  :position => :center, :header => true)

        pdf.move_down 12

        flag_is_last_grade = false
        unless Grade.where("id = ?", (@grade.id + 1)).any?
          flag_is_last_grade = true
        end

        if User.find(@student_sub_grade.student_id).gender == 0
          if flag_is_approved
            if flag_is_last_grade
              str_prom = "NO APROBÓ EL"
            else
              str_prom = "NO ES PROMOVIDA AL"
            end
          else
            str_prom = "PROMOVIDA AL"
            if flag_is_last_grade
              str_prom = "APROBÓ EL"
            end
          end
        else
          str_prom = "PROMOVIDO AL"
          if flag_is_approved
            if flag_is_last_grade
              str_prom = "NO APROBÓ EL"
            else
              str_prom = "NO ES PROMOVIDO AL"
            end
          else
            str_prom = "PROMOVIDO AL"
            if flag_is_last_grade
              str_prom = "APROBÓ EL"
            end
          end
        end
        if flag_is_last_grade
          grade_prom_name = Grade.find(@grade.id).name
        else
          grade_prom_name = Grade.find(@grade.id + 1).name
        end
        pdf.text "<b>Dictamen final de la evaluación y promoción:</b> #{str_prom} GRADO <b>#{upercase(grade_prom_name)}</b>", inline_format: true, size: 10

        pdf.move_down 12
        pdf.text "<b>Escala de valoración:</b> La presente escala se encuentra registrada en el acuerdo de evaluación institucional. Sistema de evaluación de estudiantes SEI:", inline_format: true, size: 10

        array_table_boletin = [
            [
              {
                :content => "<b>ESCALA DE VALORACION NACIONAL</b>",
                :align => :center,
                :valign => :center,
                :size => tam_str_header_table,
                :padding => [0, 2, 5, 2],
                :background_color => "E0E0E0",
                :width => 150
              },

              {
                :content => "<b>ESCALA NUMERICA</b>",
                :align => :center,
                :valign => :center,
                :size => tam_str_header_table,
                :padding => [0, 2, 5, 2],
                :background_color => "E0E0E0",
                :width => 170
              }
            ],

            [
              {
                :content => "Desempeño Superior",
                :align => :center,
                :valign => :center,
                :size => tam_str_header_table,
                :padding => [0, 2, 5, 2],
                :width => 150
              },

              {
                :content => "<b>47 - 50</b>",
                :align => :center,
                :valign => :center,
                :size => tam_str_header_table,
                :padding => [0, 2, 5, 2],
                :width => 170
              }
            ],

            [
              {
                :content => "Desempeño Alto",
                :align => :center,
                :valign => :center,
                :size => tam_str_header_table,
                :padding => [0, 2, 5, 2],
                :width => 150
              },

              {
                :content => "<b>43 - 46</b>",
                :align => :center,
                :valign => :center,
                :size => tam_str_header_table,
                :padding => [0, 2, 5, 2],
                :width => 170
              }
            ],

            [
              {
                :content => "Desempeño Básico",
                :align => :center,
                :valign => :center,
                :size => tam_str_header_table,
                :padding => [0, 2, 5, 2],
                :width => 150
              },

              {
                :content => "<b>33 - 42</b>",
                :align => :center,
                :valign => :center,
                :size => tam_str_header_table,
                :padding => [0, 2, 5, 2],
                :width => 170
              }
            ],

            [
              {
                :content => "Desempeño Bajo",
                :align => :center,
                :valign => :center,
                :size => tam_str_header_table,
                :height => 10,
                :padding => [0, 2, 5, 2],
                :width => 150
              },

              {
                :content => "<b>0 - 32</b>",
                :align => :center,
                :valign => :center,
                :size => tam_str_header_table,
                :padding => [0, 2, 5, 2],
                :width => 170
              }
            ]
          ]

        pdf.move_down 10

        pdf.table(
          array_table_boletin,
          :cell_style => {
          :borders => [:left, :right, :top, :bottom],
          :border_width => 0.1,
          :inline_format => true
        },  :position => :center, :header => true)

        pdf.move_down 12
        pdf.text "<b>El presente documenta la certificación de 40 semanas lectivas, con una duración básica de 1100 horas efectivas de trabajo anual.</b>", inline_format: true, size: 10

        pdf.move_down 12
        pdf.text "Dado en Zipaquirá, a los (07) días del mes de Diciembre de #{str_school_year}", inline_format: true, size: 10

        pdf.move_down 50
        pdf.text "<b>GLORIA DEL PILAR NIÑO NIETO</b>", inline_format: true, size: 10, align: :center
        pdf.text "<b>RECTORA</b>", inline_format: true, size: 10, align: :center
      end

    end

    archive = File.join(Rails.root,session_file,"#{t('.boletin')}_")+'.pdf'
    t = Time.now
    date_ready = t.strftime("%d-%m-%Y")
    send_file archive, :filename => "PERIODO_#{@periods.name.upcase}_#{str_sub_grade}_#{str_student_name.gsub(" ","_")}_#{t('.boletin').upcase}_#{date_ready}.pdf", :type => "application/pdf"
    FileUtils.rm_rf(Dir.glob(session_file + '/' + "#{str_sub_grade}_#{str_student_name.gsub(" ","_")}_#{t('.boletin').upcase}_#{date_ready}" + ".pdf"))
  end

  def upercase(str)
    return str.mb_chars.upcase
  end
end
