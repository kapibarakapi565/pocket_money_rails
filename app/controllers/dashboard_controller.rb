class DashboardController < ApplicationController
  before_action :set_current_user
  
  def index
    @current_month = Date.current.month
    @current_year = Date.current.year
    
    setup_personal_data
  end
  
  private
  
  def set_current_user
    # デモ用: 実際の認証実装まで仮のユーザーを使用
    @current_user = User.first || create_demo_users
  end
  
  def setup_personal_data
    @total_budget_obj = @current_user.total_budgets.find_by(
      budget_type: 'personal',
      year: @current_year,
      month: @current_month
    )
    
    @budgets = @current_user.budgets.where(
      budget_type: 'personal',
      year: @current_year,
      month: @current_month
    )
    @expenses = @current_user.expenses.joins(:budget)
                              .where(budgets: { budget_type: 'personal' })
                              .by_month(@current_year, @current_month)
    
    @total_budget = @total_budget_obj&.amount || 0
    @allocated_budget = @budgets.sum(:amount)
    @total_spent = @expenses.sum(:amount)
    @remaining = @total_budget - @total_spent
    @unallocated = @total_budget - @allocated_budget
  end
  
  
  def create_demo_users
    husband = User.create!(
      name: '夫',
      email: 'husband@example.com',
      role: 'husband'
    )
    
    wife = User.create!(
      name: '妻', 
      email: 'wife@example.com',
      role: 'wife'
    )
    
    # デモデータを作成
    create_demo_data(husband)
    
    husband
  end
  
  def create_demo_data(user)
    # カテゴリー作成
    food_category = Category.create!(
      name: '食費',
      category_type: 'personal',
      user: user
    )
    
    # 予算作成
    food_budget = Budget.create!(
      name: '食費予算',
      amount: 30000,
      budget_type: 'personal',
      user: user,
      year: Date.current.year,
      month: Date.current.month
    )
    
    # 支出作成
    Expense.create!(
      description: 'スーパーマーケット',
      amount: 2500,
      expense_date: Date.current,
      user: user,
      category: food_category,
      budget: food_budget
    )
  end
end
