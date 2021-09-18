json.array!(@companies) do |company|
  json.extract! company, :id, :name, :address, :contact, :phone
  json.url company_url(company, format: :json)
end
