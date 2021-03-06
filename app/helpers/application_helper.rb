module ApplicationHelper
	def nationalScore(num)
		case num.to_f
		when 1..3.2
			"DESEMPEÑO BAJO"
		when 3.3..3.9
			"DESEMPEÑO BÁSICO"
		when 4.0..4.5
			"DESEMPEÑO ALTO"
		else
			"DESEMPEÑO SUPERIOR"
		end
	end

	def colorScore(num)
		case num.to_f
		when 1..3.2
			"#e74c3c"
		when 3.3..3.9
			"#e67e22"
		when 4.0..4.5
			"#f1c40f"
		else
			"#2ecc71"
		end
	end

	#SELECCTOR DE IDIOMA
	def get_idiomas
		[[t('str_language_es'),1],[t('str_language_en'),2]]
	end

	def get_current_school_year(current_year)
		school_year = SchoolYear.where("name like ?", current_year.to_s)
		return school_year.first
	end

	def get_sub_grade_teacher(sub_grade_id, school_year_id, teacher_id)
		# HELPER QUE OBTIENE EL sub_grade_teacher_id
		return SubGradeTeacher.where("sub_grade_id = ? AND teacher_id = ? AND school_year_id = ?", sub_grade_id, teacher_id, school_year_id).first.id
	end

	def get_educational_performance_grades(grade_asignature_id, educational_period_id)
		# # HELPER QUE OBTIENE TODOS LOS LOGROS O DESEMPEÑOS ASOCIADOS AL GRADO Y A LA ASIGNATURA DE UN PROFESOR
		return EducationalPerformanceGrade.where("grade_asignature_id = ? AND educational_period_id = ?", grade_asignature_id, educational_period_id).pluck(:id)
	end

	def get_grade_asignature(sub_grade_id, school_year_id, educational_asignature_id)
		# HELPER QUE OBTIENE EL grade_asignature_id
		return GradeAsignature.where("educational_asignature_id = ? AND grade_id = ? AND school_year_id = ?", educational_asignature_id, get_grade(sub_grade_id), school_year_id).first.id
	end

	def get_grade(sub_grade_id)
		# HELPER QUE OBTIENE EL grade_id
		return SubGrade.find(sub_grade_id).grade
	end

	def get_current_period()
		# METODO PARA OBTENER EL PERIDO ACTUAL
		require "date"
    @educational_periods = EducationalPeriod.order(:internal_order)

    @educational_period_id_range = 0
    @educational_periods.each do |period|
      if Date.today >= period.start_date and Date.today <= period.end_date
        return period.id
        break
      end
    end
	end

	def user_status
		[["Inactivo",0],["Activo",1]].sort
	end
	def user_gender
		[["Mujer",0],["Hombre",1]].sort
	end

	def api_string
		(0...4).map{65.+(rand(25)).chr}.join.downcase
	end

	def assigned_id(model,field,id)
		puts ">>>>>>>>>>>>>>>>>>>>>>>#{model.where("#{field}=?",id).to_sql}"
		return model.where("#{field}=?",id).any?
	end

	def assigned_id_epd(id, school_year_id)
		# return false
		return EduperScoreDetail.joins("esd join educational_performance_grades epg on esd.educational_performance_grade_id = epg.id
		join educational_performances_lists el on epg.educational_performances_list_id = el.id
		join sub_grade_teachers st on esd.sub_grade_teacher_id = st.id
		join sub_grades sb on st.sub_grade_id = sb.id
		join school_years sy on st.school_year_id = sy.id").where("el.id = ? and st.school_year_id = ?", id, school_year_id).any?
		# SELECT * FROM `eduper_score_details` esd
		# join educational_performance_grades epg on esd.educational_performance_grade_id = epg.id
		# join educational_performances_lists el on epg.educational_performances_list_id = el.id
		# join sub_grade_teachers st on esd.sub_grade_teacher_id = st.id
		# join sub_grades sb on st.sub_grade_id = sb.id
		# join school_years sy on st.school_year_id = sy.id
		# where el.id = 4683 and school_year_id = 6;
	end

	def array_score_five
		[
			[0.1, 0.1],
			[0.2, 0.2],
			[0.3, 0.3],
			[0.4, 0.4],
			[0.5, 0.5],
			[0.6, 0.6],
			[0.7, 0.7],
			[0.8, 0.8],
			[0.9, 0.9],
			[1.0, 1.0],
			[1.1, 1.1],
			[1.2, 1.2],
			[1.3, 1.3],
			[1.4, 1.4],
			[1.5, 1.5],
			[1.6, 1.6],
			[1.7, 1.7],
			[1.8, 1.8],
			[1.9, 1.9],
			[2.0, 2.0],
			[2.1, 2.1],
			[2.2, 2.2],
			[2.3, 2.3],
			[2.4, 2.4],
			[2.5, 2.5],
			[2.6, 2.6],
			[2.7, 2.7],
			[2.8, 2.8],
			[2.9, 2.9],
			[3.0, 3.0],
			[3.1, 3.1],
			[3.2, 3.2],
			[3.3, 3.3],
			[3.4, 3.4],
			[3.5, 3.5],
			[3.6, 3.6],
			[3.7, 3.7],
			[3.8, 3.8],
			[3.9, 3.9],
			[4.0, 4.0],
			[4.1, 4.1],
			[4.2, 4.2],
			[4.3, 4.3],
			[4.4, 4.4],
			[4.5, 4.5],
			[4.6, 4.6],
			[4.7, 4.7],
			[4.8, 4.8],
			[4.9, 4.9],
			[5.0, 5.0]
		]
	end

	def array_score_ten
		[
			[0.1, 0.1],
			[0.2, 0.2],
			[0.3, 0.3],
			[0.4, 0.4],
			[0.5, 0.5],
			[0.6, 0.6],
			[0.7, 0.7],
			[0.8, 0.8],
			[0.9, 0.9],
			[1.0, 1.0],
			[1.1, 1.1],
			[1.2, 1.2],
			[1.3, 1.3],
			[1.4, 1.4],
			[1.5, 1.5],
			[1.6, 1.6],
			[1.7, 1.7],
			[1.8, 1.8],
			[1.9, 1.9],
			[2.0, 2.0],
			[2.1, 2.1],
			[2.2, 2.2],
			[2.3, 2.3],
			[2.4, 2.4],
			[2.5, 2.5],
			[2.6, 2.6],
			[2.7, 2.7],
			[2.8, 2.8],
			[2.9, 2.9],
			[3.0, 3.0],
			[3.1, 3.1],
			[3.2, 3.2],
			[3.3, 3.3],
			[3.4, 3.4],
			[3.5, 3.5],
			[3.6, 3.6],
			[3.7, 3.7],
			[3.8, 3.8],
			[3.9, 3.9],
			[4.0, 4.0],
			[4.1, 4.1],
			[4.2, 4.2],
			[4.3, 4.3],
			[4.4, 4.4],
			[4.5, 4.5],
			[4.6, 4.6],
			[4.7, 4.7],
			[4.8, 4.8],
			[4.9, 4.9],
			[5.0, 5.0],
			[5.1, 5.1],
			[5.2, 5.2],
			[5.3, 5.3],
			[5.4, 5.4],
			[5.5, 5.5],
			[5.6, 5.6],
			[5.7, 5.7],
			[5.8, 5.8],
			[5.9, 5.9],
			[6.0, 6.0],
			[6.1, 6.1],
			[6.2, 6.2],
			[6.3, 6.3],
			[6.4, 6.4],
			[6.5, 6.5],
			[6.6, 6.6],
			[6.7, 6.7],
			[6.8, 6.8],
			[6.9, 6.9],
			[7.0, 7.0],
			[7.1, 7.1],
			[7.2, 7.2],
			[7.3, 7.3],
			[7.4, 7.4],
			[7.5, 7.5],
			[7.6, 7.6],
			[7.7, 7.7],
			[7.8, 7.8],
			[7.9, 7.9],
			[8.0, 8.0],
			[8.1, 8.1],
			[8.2, 8.2],
			[8.3, 8.3],
			[8.4, 8.4],
			[8.5, 8.5],
			[8.6, 8.6],
			[8.7, 8.7],
			[8.8, 8.8],
			[8.9, 8.9],
			[9.0, 9.0],
			[9.1, 9.1],
			[9.2, 9.2],
			[9.3, 9.3],
			[9.4, 9.4],
			[9.5, 9.5],
			[9.6, 9.6],
			[9.7, 9.7],
			[9.8, 9.8],
			[9.9, 9.9],
			[10.0, 10.0]
		]
	end

	def array_percentage
		per_array = Array.new
		(1..100).each do |per|
			per_array << ["#{per} %", per]
		end
		return per_array
	end

	def exist_student_sub_grade(students_grade_id)
		StudentSubGrade.where("students_grade_id=?",students_grade_id)
	end
end
