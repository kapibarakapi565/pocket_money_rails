class Budget < ApplicationRecord
  belongs_to :user
  has_many :expenses, dependent: :destroy
  
  validates :name, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :budget_type, inclusion: { in: %w[personal household] }
  validates :year, presence: true
  validates :month, presence: true, inclusion: { in: 1..12 }
  
  enum budget_type: { personal: 'personal', household: 'household' }
  
  # 並び順でソート
  scope :ordered, -> { order(:sort_order, :created_at) }
  
  # 新規作成時に最大のsort_orderを設定
  before_create :set_sort_order
  
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
  
  private
  
  def set_sort_order
    max_order = user.budgets.where(
      budget_type: budget_type,
      year: year,
      month: month
    ).maximum(:sort_order) || 0
    self.sort_order = max_order + 1
  end
end
