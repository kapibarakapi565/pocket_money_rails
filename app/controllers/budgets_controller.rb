class BudgetsController < ApplicationController
  before_action :set_current_user
  include ActionView::Helpers::NumberHelper

  def create
    year = params[:year]&.to_i || Date.current.year
    month = params[:month]&.to_i || Date.current.month
    user_type = params[:user_type]
    
    @budget = Budget.new(budget_params)
    @budget.user = @current_user
    @budget.year = year
    @budget.month = month

    # 総予算チェック
    total_budget = @current_user.total_budgets.find_by(
      budget_type: @budget.budget_type,
      year: @budget.year,
      month: @budget.month
    )
    
    if total_budget
      current_allocated = @current_user.budgets.where(
        budget_type: @budget.budget_type,
        year: @budget.year,
        month: @budget.month
      ).sum(:amount)
      
      if current_allocated + @budget.amount > total_budget.amount
        redirect_to dashboard_path(year: year, month: month, user_type: user_type), 
                    alert: "総予算を超過します。残り予算: ¥#{number_with_delimiter((total_budget.amount - current_allocated).to_i)}"
        return
      end
    end

    if @budget.save
      redirect_to dashboard_path(year: year, month: month, user_type: user_type), notice: '予算が追加されました'
    else
      redirect_to dashboard_path(year: year, month: month, user_type: user_type), alert: '予算の追加に失敗しました'
    end
  end

  def edit
    @budget = Budget.find(params[:id])
  end

  def update
    @budget = Budget.find(params[:id])
    year = @budget.year
    month = @budget.month
    user_type = params[:user_type]
    
    # 総予算チェック（編集時）
    total_budget = @current_user.total_budgets.find_by(
      budget_type: @budget.budget_type,
      year: @budget.year,
      month: @budget.month
    )
    
    if total_budget
      current_allocated = @current_user.budgets.where(
        budget_type: @budget.budget_type,
        year: @budget.year,
        month: @budget.month
      ).where.not(id: @budget.id).sum(:amount)
      
      new_amount = budget_params[:amount].to_f
      if current_allocated + new_amount > total_budget.amount
        redirect_to dashboard_path(year: year, month: month, user_type: user_type), 
                    alert: "総予算を超過します。残り予算: ¥#{number_with_delimiter((total_budget.amount - current_allocated).to_i)}"
        return
      end
    end

    if @budget.update(budget_params)
      redirect_to dashboard_path(year: year, month: month, user_type: user_type), notice: '予算が更新されました'
    else
      redirect_to dashboard_path(year: year, month: month, user_type: user_type), alert: '予算の更新に失敗しました'
    end
  end

  def destroy
    @budget = Budget.find(params[:id])
    year = @budget.year
    month = @budget.month
    user_type = params[:user_type]
    @budget.destroy
    redirect_to dashboard_path(year: year, month: month, user_type: user_type), notice: '予算が削除されました'
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

  def budget_params
    params.require(:budget).permit(:name, :amount, :budget_type)
  end
end
