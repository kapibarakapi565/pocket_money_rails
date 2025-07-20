class Budget < ApplicationRecord
  belongs_to :user
  has_many :expenses, dependent: :destroy
  
  validates :name, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :budget_type, inclusion: { in: %w[personal household] }
  validates :year, presence: true
  validates :month, presence: true, inclusion: { in: 1..12 }
  
  enum budget_type: { personal: 'personal', household: 'household' }
  
  def spent_amount
    expenses.sum(:amount)
  end
  
  def remaining_amount
    amount - spent_amount
  end
  
  def usage_percentage
    return 0 if amount.zero?
    
    (spent_amount / amount * 100).round(2)
  end
end
