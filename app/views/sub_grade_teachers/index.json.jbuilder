json.array!(@sub_grade_teachers) do |sub_grade_teacher|
  json.extract! sub_grade_teacher, :id, :teacher_id, :sub_grade_id
  json.url sub_grade_teacher_url(sub_grade_teacher, format: :json)
end
