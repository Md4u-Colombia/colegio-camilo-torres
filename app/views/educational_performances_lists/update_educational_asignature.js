$("#educational_asignature_id").empty().prepend("<option value='' selected='selected'>Seleccione Asignatura</option>").append("<%= escape_javascript(render(:partial => @update_educational_asignature)) %>")
