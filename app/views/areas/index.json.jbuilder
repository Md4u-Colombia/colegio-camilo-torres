json.array!(@areas) do |area|
  json.extract! area, :id, :name, :parent_id, :status
  json.url area_url(area, format: :json)
end
