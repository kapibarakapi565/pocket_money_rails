class BudgetsController < ApplicationController
  before_action :set_current_user
  include ActionView::Helpers::NumberHelper

  def create
    @budget = Budget.new(budget_params)
    @budget.user = @current_user
    @budget.year = Date.current.year
    @budget.month = Date.current.month

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
        redirect_to dashboard_path, 
                    alert: "総予算を超過します。残り予算: ¥#{number_with_delimiter((total_budget.amount - current_allocated).to_i)}"
        return
      end
    end

    if @budget.save
      redirect_to dashboard_path, notice: '予算が追加されました'
    else
      redirect_to dashboard_path, alert: '予算の追加に失敗しました'
    end
  end

  def destroy
    @budget = Budget.find(params[:id])
    @budget.destroy
    redirect_to dashboard_path, notice: '予算が削除されました'
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

  def budget_params
    params.require(:budget).permit(:name, :amount, :budget_type)
  end
end
