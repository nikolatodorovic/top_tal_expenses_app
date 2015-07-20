class CreateExpenses < ActiveRecord::Migration
  def change
    create_table :expenses do |t|
      t.integer :user_id, null: false
      t.decimal :amount, precision: 12, scale: 3, null: false
      t.datetime :for_timeday
      t.text :description, null: false
      t.text :comment
      t.timestamps
    end
  end
end
