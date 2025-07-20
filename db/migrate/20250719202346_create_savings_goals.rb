class CreateSavingsGoals < ActiveRecord::Migration[7.1]
  def change
    create_table :savings_goals do |t|
      t.string :name
      t.decimal :target_amount
      t.decimal :current_amount
      t.references :user, null: false, foreign_key: true
      t.integer :year
      t.integer :month

      t.timestamps
    end
  end
end
