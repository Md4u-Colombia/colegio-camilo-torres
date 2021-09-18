json.array!(@students_grades) do |students_grade|
  json.extract! students_grade, :id, :student_id, :grade_id, :school_year_id, :status
  json.url students_grade_url(students_grade, format: :json)
end
