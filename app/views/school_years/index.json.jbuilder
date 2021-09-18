json.array!(@school_years) do |school_year|
  json.extract! school_year, :id, :name, :description, :date_begin, :date_end
  json.url school_year_url(school_year, format: :json)
end
