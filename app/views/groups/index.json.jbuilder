json.array!(@groups) do |group|
  json.extract! group, :id, :name, :parent_id, :status
  json.url group_url(group, format: :json)
end
