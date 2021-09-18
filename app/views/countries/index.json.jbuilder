json.array!(@countries) do |country|
  json.extract! country, :id, :name, :language_id
  json.url country_url(country, format: :json)
end
