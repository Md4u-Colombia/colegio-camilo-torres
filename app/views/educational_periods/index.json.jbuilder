json.array!(@educational_periods) do |educational_period|
  json.extract! educational_period, :id, :name, :weight, :weight, :school_year_id
  json.url educational_period_url(educational_period, format: :json)
end
