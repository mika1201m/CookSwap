class CreateRecipes < ActiveRecord::Migration[7.1]
  def change
    create_table :recipes do |t|
      t.string :title, null: false
      t.text :process, null: false
      t.integer :genre, null: false
      t.integer :release, null: false, default: 0

      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
