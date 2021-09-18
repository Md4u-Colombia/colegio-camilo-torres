json.array!(@student_progresses) do |student_progress|
  json.extract! student_progress, :id, :student_sub_grade_id, :educational_asignature, :educational_performance_id
  json.url student_progress_url(student_progress, format: :json)
end
