json.array!(@educational_areas) do |educational_area|
  json.extract! educational_area, :id, :grade_id, :name, :description
  json.url educational_area_url(educational_area, format: :json)
end
