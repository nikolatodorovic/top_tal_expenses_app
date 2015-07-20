json.array!(@expenses) do |expenses|
  json.extract! expenses, :id, :amount, :for_timeday, :description, :comment
end
