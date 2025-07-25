class ExpensesController < ApplicationController
  before_action :set_current_user

  def create
    @budget = Budget.find(params[:expense][:budget_id])
    @expense = Expense.new(expense_params)
    @expense.user = @current_user
    @expense.budget = @budget
    
    # カテゴリを作成または取得
    @category = Category.find_or_create_by(
      name: @budget.name,
      user: @current_user,
      category_type: @budget.budget_type
    )
    @expense.category = @category

    year = @budget.year
    month = @budget.month
    user_type = params[:user_type]

    if @expense.save
      respond_to do |format|
        format.html { redirect_to dashboard_path(year: year, month: month, user_type: user_type), notice: '支出が追加されました' }
        format.turbo_stream { redirect_to dashboard_path(year: year, month: month, user_type: user_type) }
      end
    else
      respond_to do |format|
        format.html { redirect_to dashboard_path(year: year, month: month, user_type: user_type), alert: '支出の追加に失敗しました' }
        format.turbo_stream { redirect_to dashboard_path(year: year, month: month, user_type: user_type) }
      end
    end
  end

  def destroy
    @expense = Expense.find(params[:id])
    year = @expense.budget.year
    month = @expense.budget.month
    user_type = params[:user_type]
    @expense.destroy
    respond_to do |format|
      format.html { redirect_to dashboard_path(year: year, month: month, user_type: user_type), notice: '支出が削除されました' }
      format.turbo_stream { redirect_to dashboard_path(year: year, month: month, user_type: user_type) }
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

  def expense_params
    params.require(:expense).permit(:description, :amount, :expense_date, :budget_id)
  end
end
