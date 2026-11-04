class CreateClients < ActiveRecord::Migration[7.1]
  def change
    create_table :clients do |t|
      t.references :organization, null: false, foreign_key: true

      t.string :name, null: false
      t.string :email
      t.string :phone
      t.string :status, null: false, default: "active"

      t.timestamps
    end

    add_index :clients, [:organization_id, :name]
  end
end