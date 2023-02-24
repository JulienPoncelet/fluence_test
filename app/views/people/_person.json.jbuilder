json.extract! person, :id, :reference, :email, :home_phone_number, :mobile_phone_number, :firstname, :lastname, :address, :created_at, :updated_at
json.url person_url(person, format: :json)
