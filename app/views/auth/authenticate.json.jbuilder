json.user do
  json.extract! @user, :id, :email, :first_name, :last_name, :id_role
end

json.token @token