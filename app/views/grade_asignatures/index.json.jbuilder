json.array!(@grade_asignatures) do |grade_asignature|
  json.extract! grade_asignature, :id, :educational_asignature_id, :grade_id, :internal_order
  json.url grade_asignature_url(grade_asignature, format: :json)
end
