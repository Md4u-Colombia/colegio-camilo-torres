$("#teacher_asignature_sub_grade_id").empty().prepend("<option value='' selected='selected'><%= t('str_select_field') + " " + t('.sub_grade_id') %></option>").append("<%= escape_javascript(render(:partial => @update_sub_grade)) %>")