json.array!(@student_trackings) do |student_tracking|
  json.extract! student_tracking, :id, :score_detail_id, :educational_period_id, :score, :compliance
  json.url student_tracking_url(student_tracking, format: :json)
end
