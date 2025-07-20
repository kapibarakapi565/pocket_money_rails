class Category < ApplicationRecord
  belongs_to :user
  has_many :expenses, dependent: :destroy
  
  validates :name, presence: true
  validates :category_type, inclusion: { in: %w[personal household] }
  
  enum category_type: { personal: 'personal', household: 'household' }
end
