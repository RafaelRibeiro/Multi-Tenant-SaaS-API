class CreateOrganizations < ActiveRecord::Migration[7.1]
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.integer :status, null: false, default: 0

      t.timestamps

      t.index :slug, unique: true
    end
  end
end