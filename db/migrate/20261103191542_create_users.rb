class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false

      t.timestamps

      t.index "LOWER(email)", unique: true, name: "index_users_on_lower_email"
    end
  end
end