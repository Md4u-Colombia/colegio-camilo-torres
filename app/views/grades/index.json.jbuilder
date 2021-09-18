json.array!(@grades) do |grade|
  json.extract! grade, :id, :education_level_id, :name, :description
  json.url grade_url(grade, format: :json)
end
