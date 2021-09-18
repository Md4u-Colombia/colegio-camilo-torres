json.array!(@eduper_score_details) do |eduper_score_detail|
  json.extract! eduper_score_detail, :id, :name, :description, :educational_performance_id, :sd_detail_id, :sub_grade_teacher_id, :weight
  json.url eduper_score_detail_url(eduper_score_detail, format: :json)
end
