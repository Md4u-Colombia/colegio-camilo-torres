json.array!(@average_student_sub_grades) do |average_student_sub_grade|
  json.extract! average_student_sub_grade, :id, :student_sub_grade_id, :educational_period_id, :average, :average
  json.url average_student_sub_grade_url(average_student_sub_grade, format: :json)
end
