json.array!(@positions) do |position|
  json.extract! position, :id, :name, :position_level_id, :description, :status
  json.url position_url(position, format: :json)
end
