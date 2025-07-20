class TotalBudgetsController < ApplicationController
  before_action :set_current_user

  def create
    @total_budget = TotalBudget.find_or_initialize_by(
      user: @current_user,
      budget_type: total_budget_params[:budget_type],
      year: Date.current.year,
      month: Date.current.month
    )
    
    @total_budget.amount = total_budget_params[:amount]

    if @total_budget.save
      redirect_to dashboard_path, notice: '総予算が設定されました'
    else
      redirect_to dashboard_path, alert: '総予算の設定に失敗しました'
    end
  end

  def update
    @total_budget = TotalBudget.find(params[:id])
    
    if @total_budget.update(total_budget_params)
      redirect_to dashboard_path, notice: '総予算が更新されました'
    else
      redirect_to dashboard_path, alert: '総予算の更新に失敗しました'
    end
  end

  private

  def set_current_user
    @current_user = User.first || create_demo_users
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
    
    husband
  end

  def total_budget_params
    params.require(:total_budget).permit(:amount, :budget_type)
  end
end
