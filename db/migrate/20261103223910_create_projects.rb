class CreateProjects < ActiveRecord::Migration[7.1]
  def change
    create_table :projects do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :client, null: true, foreign_key: true

      t.string :name, null: false
      t.text :description
      t.string :status, null: false, default: "planning"

      t.date :start_date
      t.date :end_date

      t.timestamps
    end

    add_index :projects, [:organization_id, :name]
  end
end