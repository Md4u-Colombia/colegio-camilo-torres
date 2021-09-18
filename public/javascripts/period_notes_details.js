# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
	$(document).on 'change', '#period_notes_detail_teacher_asignature_id', (evt) ->
		alert "Entra";
		$.ajax 'period_notes_details',
		type: 'GET'
		dataType: 'script'
		data: {
			pndt_asignature_id: $("#period_notes_detail_teacher_asignature_id option:selected").val()
		}
		error: (jqXHR, textStatus, errorThrown) ->
			console.log("AJAX Error: #{textStatus}")
		success: (data, textStatus, jqXHR) ->
			alert data;
			console.log("Dynamic country select OK!")
