class AddSortOrderToBudgets < ActiveRecord::Migration[7.1]
  def change
    add_column :budgets, :sort_order, :integer, default: 0
    add_index :budgets, :sort_order
  end
end
