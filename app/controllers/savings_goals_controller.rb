class SavingsGoalsController < ApplicationController
  before_action :set_current_user

  def create
    @savings_goal = SavingsGoal.new(savings_goal_params)

    if @savings_goal.save
      redirect_to dashboard_path(mode: 'household'), notice: '貯金目標が追加されました'
    else
      redirect_to dashboard_path(mode: 'household'), alert: '貯金目標の追加に失敗しました'
    end
  end

  def destroy
    @savings_goal = SavingsGoal.find(params[:id])
    @savings_goal.destroy
    redirect_to dashboard_path(mode: 'household'), notice: '貯金目標が削除されました'
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

  def savings_goal_params
    params.require(:savings_goal).permit(:name, :target_amount, :year, :month)
  end
end
