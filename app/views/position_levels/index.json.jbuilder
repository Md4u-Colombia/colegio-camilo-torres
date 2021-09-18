json.array!(@position_levels) do |position_level|
  json.extract! position_level, :id, :name
  json.url position_level_url(position_level, format: :json)
end
