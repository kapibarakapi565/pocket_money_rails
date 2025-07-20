class CreateTotalBudgets < ActiveRecord::Migration[7.1]
  def change
    create_table :total_budgets do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.string :budget_type, null: false
      t.integer :year, null: false
      t.integer :month, null: false

      t.timestamps
    end

    add_index :total_budgets, [:user_id, :budget_type, :year, :month], unique: true, name: 'index_total_budgets_unique'
  end
end
