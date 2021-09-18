json.array!(@student_sub_grades) do |student_sub_grade|
  json.extract! student_sub_grade, :id, :student_id, :school_year_id, :sub_grade_id
  json.url student_sub_grade_url(student_sub_grade, format: :json)
end
