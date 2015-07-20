json.array!(@users) do |users|
  json.extract! users, :id, :first_name, :last_name, :email, :id_role
end
