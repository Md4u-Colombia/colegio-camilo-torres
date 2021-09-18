json.array!(@sub_grades) do |sub_grade|
  json.extract! sub_grade, :id, :grade_id, :course_director_id, :name, :description
  json.url sub_grade_url(sub_grade, format: :json)
end
