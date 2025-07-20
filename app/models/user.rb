class User < ApplicationRecord
  has_many :categories, dependent: :destroy
  has_many :budgets, dependent: :destroy
  has_many :expenses, dependent: :destroy
  has_many :savings_goals, dependent: :destroy
  has_many :total_budgets, dependent: :destroy
  
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :role, inclusion: { in: %w[husband wife] }
  
  enum role: { husband: 'husband', wife: 'wife' }
end
