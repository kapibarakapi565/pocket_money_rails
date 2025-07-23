class TotalBudgetsController < ApplicationController
  before_action :set_current_user

  def create
    year = params[:year]&.to_i || Date.current.year
    month = params[:month]&.to_i || Date.current.month
    user_type = params[:user_type]
    
    @total_budget = TotalBudget.find_or_initialize_by(
      user: @current_user,
      budget_type: total_budget_params[:budget_type],
      year: year,
      month: month
    )
    
    @total_budget.amount = total_budget_params[:amount]

    if @total_budget.save
      redirect_to dashboard_path(year: year, month: month, user_type: user_type), notice: '総予算が設定されました'
    else
      redirect_to dashboard_path(year: year, month: month, user_type: user_type), alert: '総予算の設定に失敗しました'
    end
  end

  def update
    @total_budget = TotalBudget.find(params[:id])
    user_type = params[:user_type]
    
    if @total_budget.update(total_budget_params)
      redirect_to dashboard_path(year: @total_budget.year, month: @total_budget.month, user_type: user_type), notice: '総予算が更新されました'
    else
      redirect_to dashboard_path(year: @total_budget.year, month: @total_budget.month, user_type: user_type), alert: '総予算の更新に失敗しました'
    end
  end

  private

  def set_current_user
    # ユーザー切り替え機能
    if params[:user_type] == 'wife'
      @current_user = User.find_by(role: 'wife') || create_demo_users
      @current_user = User.find_by(role: 'wife') if @current_user.role != 'wife'
    elsif params[:user_type] == 'household'
      @current_user = User.first || create_demo_users
      @view_type = 'household'
    else
      @current_user = User.find_by(role: 'husband') || create_demo_users
    end
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
