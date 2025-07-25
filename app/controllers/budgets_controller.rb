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
      respond_to do |format|
        format.html { redirect_to dashboard_path(year: year, month: month, user_type: user_type), notice: '予算が追加されました' }
        format.turbo_stream { redirect_to dashboard_path(year: year, month: month, user_type: user_type) }
      end
    else
      respond_to do |format|
        format.html { redirect_to dashboard_path(year: year, month: month, user_type: user_type), alert: '予算の追加に失敗しました' }
        format.turbo_stream { redirect_to dashboard_path(year: year, month: month, user_type: user_type) }
      end
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
      respond_to do |format|
        format.html { redirect_to dashboard_path(year: year, month: month, user_type: user_type), notice: '予算が更新されました' }
        format.turbo_stream { redirect_to dashboard_path(year: year, month: month, user_type: user_type) }
      end
    else
      respond_to do |format|
        format.html { redirect_to dashboard_path(year: year, month: month, user_type: user_type), alert: '予算の更新に失敗しました' }
        format.turbo_stream { redirect_to dashboard_path(year: year, month: month, user_type: user_type) }
      end
    end
  end

  def destroy
    @budget = Budget.find(params[:id])
    year = @budget.year
    month = @budget.month
    user_type = params[:user_type]
    @budget.destroy
    respond_to do |format|
      format.html { redirect_to dashboard_path(year: year, month: month, user_type: user_type), notice: '予算が削除されました' }
      format.turbo_stream { redirect_to dashboard_path(year: year, month: month, user_type: user_type) }
    end
  end
  
  
  def reorder
    @budget = Budget.find(params[:id])
    new_index = params[:new_index].to_i
    user_type = params[:user_type]
    
    # 同じユーザー・タイプ・年月の予算一覧を取得
    budgets = @current_user.budgets.where(
      budget_type: @budget.budget_type,
      year: @budget.year,
      month: @budget.month
    ).ordered.to_a
    
    # 現在の位置を取得
    old_index = budgets.index(@budget)
    return if old_index.nil? || old_index == new_index
    
    # 配列から要素を削除して新しい位置に挿入
    budgets.delete_at(old_index)
    budgets.insert(new_index, @budget)
    
    # sort_orderを再設定
    budgets.each_with_index do |budget, index|
      budget.update_column(:sort_order, index + 1)
    end
    
    head :ok
  end
  
  def copy_to_next_month
    year = params[:year]&.to_i || Date.current.year
    month = params[:month]&.to_i || Date.current.month
    user_type = params[:user_type]
    
    current_date = Date.new(year, month, 1)
    next_month_date = current_date + 1.month
    next_year = next_month_date.year
    next_month = next_month_date.month
    
    budget_type = user_type == 'household' ? 'household' : 'personal'
    
    # 現在月の予算を取得
    current_budgets = @current_user.budgets.where(
      budget_type: budget_type,
      year: year,
      month: month
    ).ordered
    
    # 次月に既に予算があるかチェック
    existing_budgets = @current_user.budgets.where(
      budget_type: budget_type,
      year: next_year,
      month: next_month
    )
    
    if existing_budgets.exists?
      redirect_to dashboard_path(year: year, month: month, user_type: user_type), 
                  alert: "#{next_year}年#{next_month}月には既に予算が設定されています"
      return
    end
    
    # 総予算もコピー
    current_total_budget = @current_user.total_budgets.find_by(
      budget_type: budget_type,
      year: year,
      month: month
    )
    
    copied_count = 0
    
    ActiveRecord::Base.transaction do
      # 総予算をコピー
      if current_total_budget
        @current_user.total_budgets.create!(
          budget_type: budget_type,
          year: next_year,
          month: next_month,
          amount: current_total_budget.amount
        )
      end
      
      # 個別予算をコピー
      current_budgets.each_with_index do |budget, index|
        @current_user.budgets.create!(
          name: budget.name,
          amount: budget.amount,
          budget_type: budget_type,
          year: next_year,
          month: next_month,
          sort_order: index + 1
        )
        copied_count += 1
      end
    end
    
    redirect_to dashboard_path(year: next_year, month: next_month, user_type: user_type), 
                notice: "#{copied_count}件の予算を#{next_year}年#{next_month}月にコピーしました"
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
