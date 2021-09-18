json.array!(@sd_details) do |sd_detail|
  json.extract! sd_detail, :id, :name
  json.url sd_detail_url(sd_detail, format: :json)
end
