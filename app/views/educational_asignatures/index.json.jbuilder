json.array!(@educational_asignatures) do |educational_asignature|
  json.extract! educational_asignature, :id, :educational_area_id, :name, :description
  json.url educational_asignature_url(educational_asignature, format: :json)
end
