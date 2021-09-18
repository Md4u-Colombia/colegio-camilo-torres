json.array!(@period_notes_details) do |period_notes_detail|
  json.extract! period_notes_detail, :id, :school_year_id, :teacher_asignature_id, :educational_performance_id, :performance_weight, :sd_detail_id, :detail_weight, :educational_period_id, :period_weight, :teacher_id
  json.url period_notes_detail_url(period_notes_detail, format: :json)
end
