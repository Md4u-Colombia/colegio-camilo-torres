json.array!(@teacher_asignatures) do |teacher_asignature|
  json.extract! teacher_asignature, :id, :teacher_id, :sub_grade_id, :educational_asignature_id
  json.url teacher_asignature_url(teacher_asignature, format: :json)
end
