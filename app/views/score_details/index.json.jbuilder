json.array!(@score_details) do |score_detail|
  json.extract! score_detail, :id, :sd_detail_id, :educational_period_id, :sub_grade_teacher_id, :educational_asignature_id, :weight
  json.url score_detail_url(score_detail, format: :json)
end
