class Expense < ApplicationRecord
  belongs_to :user
  belongs_to :category
  belongs_to :budget
  
  validates :description, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :expense_date, presence: true
  
  scope :by_month, ->(year, month) { where(expense_date: Date.new(year, month, 1)..Date.new(year, month, -1)) }
  scope :personal, -> { joins(:budget).where(budgets: { budget_type: 'personal' }) }
  scope :household, -> { joins(:budget).where(budgets: { budget_type: 'household' }) }
end
