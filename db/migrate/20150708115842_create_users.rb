class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :password_digest
      t.string :first_name
      t.string :last_name
      t.integer :id_role, default: 1

      t.timestamps null: false

      t.index :email, unique: true
    end
  end
end
