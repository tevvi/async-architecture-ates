class AnalyticsController < ApplicationController
  def index
    redirect_to '/' unless current_account.role_admin?

    task_groups = Task.where(status: :finished, finished_at: 1.month.ago..Time.current).group_by { |el| el.finished_at.to_date }
    tasks = task_groups.map { |date, group| [date, group.max_by(&:price)] }.to_h
    # Это все нужно потому что может быть так что за один день никто не выполнит задачу, и за этот день макс таски не будет
    weekly_max_task = tasks.values.select { |task| (1.week.ago..Time.current).include?(task.finished_at) }.max_by(&:price)
    monthly_max_task = tasks.values.select { |task| (1.month.ago..Time.current).include?(task.finished_at) }.max_by(&:price)
    result = {
      today_max_task: tasks[Time.current.today],
      weekly_max_task: weekly_max_task,
      monthly_max_task: monthly_max_task
    }
    render json: result
  end
end