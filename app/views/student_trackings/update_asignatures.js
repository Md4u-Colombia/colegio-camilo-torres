$("#score_detail_educational_asignature_id").empty().prepend("<option value='' selected='selected'><%= t('str_select_field') %> Asignatura</option>").append("<%= escape_javascript(render(:partial => @educational_asignatures)) %>")