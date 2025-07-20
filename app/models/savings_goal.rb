class SavingsGoal < ApplicationRecord
  belongs_to :user
  
  validates :name, presence: true
  validates :target_amount, presence: true, numericality: { greater_than: 0 }
  validates :current_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :year, presence: true
  validates :month, presence: true, inclusion: { in: 1..12 }
  
  def achievement_percentage
    return 0 if target_amount.zero?
    
    (current_amount / target_amount * 100).round(2)
  end
  
  def remaining_amount
    target_amount - current_amount
  end
  
  def achieved?
    current_amount >= target_amount
  end
end
