json.array!(@localizations) do |localization|
  json.extract! localization, :id, :name, :parent_id, :status
  json.url localization_url(localization, format: :json)
end
