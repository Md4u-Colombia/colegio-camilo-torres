json.array!(@business_units) do |business_unit|
  json.extract! business_unit, :id, :name, :status
  json.url business_unit_url(business_unit, format: :json)
end
