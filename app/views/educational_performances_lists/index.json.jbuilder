json.array!(@educational_performances_lists) do |educational_performances_list|
  json.extract! educational_performances_list, :id, :name, :status
  json.url educational_performances_list_url(educational_performances_list, format: :json)
end
