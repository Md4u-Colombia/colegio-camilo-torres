$("#students_grade_student_id").empty().prepend("<option value='' selected='selected'>Seleccione Alumno</option>").append("<%= escape_javascript(render(:partial => @update_students)) %>")