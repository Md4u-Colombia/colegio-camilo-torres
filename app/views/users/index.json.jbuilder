json.array!(@users) do |user|
  json.extract! user, :id, :name, :last_name, :username, :email, :encrypted_password, :identity, :gender, :since_date, :company_id, :area_id, :localization_id, :position_id, :group_id, :business_unite_id, :country_id, :city_id, :status
  json.url user_url(user, format: :json)
end
