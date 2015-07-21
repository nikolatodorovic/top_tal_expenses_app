json.array!(@expenses) do |expenses|
  json.extract! expenses, :id, :amount, :for_timeday, :description, :comment
  json.user expenses.user, :first_name, :last_name
end
