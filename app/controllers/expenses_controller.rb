class ExpensesController < ApplicationController
  before_action :set_current_user

  def create
    @budget = Budget.find(params[:expense][:budget_id])
    @expense = Expense.new(expense_params)
    @expense.user = @current_user
    @expense.budget = @budget
    @expense.category = @budget.category
    @expense.expense_date = Date.current

    year = @budget.year
    month = @budget.month

    if @expense.save
      redirect_to dashboard_path(year: year, month: month), notice: '支出が追加されました'
    else
      redirect_to dashboard_path(year: year, month: month), alert: '支出の追加に失敗しました'
    end
  end

  def destroy
    @expense = Expense.find(params[:id])
    year = @expense.budget.year
    month = @expense.budget.month
    @expense.destroy
    redirect_to dashboard_path(year: year, month: month), notice: '支出が削除されました'
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

  def expense_params
    params.require(:expense).permit(:description, :amount, :budget_id)
  end
end
