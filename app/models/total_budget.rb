class TotalBudget < ApplicationRecord
  belongs_to :user
  
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :budget_type, inclusion: { in: %w[personal household] }
  validates :year, presence: true
  validates :month, presence: true, inclusion: { in: 1..12 }
  validates :user_id, uniqueness: { scope: [:budget_type, :year, :month] }
  
  enum budget_type: { personal: 'personal', household: 'household' }
  
  def category_budgets
    Budget.where(
      user: user,
      budget_type: budget_type,
      year: year,
      month: month
    )
  end
  
  def allocated_amount
    category_budgets.sum(:amount)
  end
  
  def remaining_amount
    amount - allocated_amount
  end
  
  def allocation_percentage
    return 0 if amount.zero?
    
    (allocated_amount / amount * 100).round(2)
  end
end
