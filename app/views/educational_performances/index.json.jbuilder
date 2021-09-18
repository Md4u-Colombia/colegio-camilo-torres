json.array!(@educational_performances) do |educational_performance|
  json.extract! educational_performance, :id, :description, :educational_period_id, :educational_asignature_id, :school_year_id
  json.url educational_performance_url(educational_performance, format: :json)
end
