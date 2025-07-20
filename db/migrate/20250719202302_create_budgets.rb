class CreateBudgets < ActiveRecord::Migration[7.1]
  def change
    create_table :budgets do |t|
      t.string :name
      t.decimal :amount
      t.string :budget_type
      t.references :user, null: false, foreign_key: true
      t.integer :year
      t.integer :month

      t.timestamps
    end
  end
end
