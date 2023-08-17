class AccountingController < ApplicationController
  def index
    result = {}

    if current_account.role_admin? || current_account.role_bookkeeper?
      # Когда начнутся просадки в этом месте, можно начать делать агрегацию данных
      # Например в конце рабочего дня прочитывать TopManagementProfit: сумма debit и credit
      # для log_type: ['TaskAssigned', 'TaskCompleted'] за сегодняшний день, выбирать данные:
      # BalanceLog.where( log_type: 'TopManagementProfit', created_at: 30.days.ago.to_date..Time.current.to_date)
      logs = BalanceLog.where(
        log_type: ['TaskAssigned', 'TaskCompleted'],
        created_at: 30.days.ago.to_date..Time.current.to_date).group_by { |el| el.created_at.to_date }
      today_logs = logs[Time.current.to_date]
      result[:today_balance] = today_logs.sum(&:debit) - today_logs.sum(&:credit)
      result[:balance_statistic] = logs.map do |date, logs_group|
        [date, logs_group.sum(&:debit) - logs_group.sum(&:credit)]
      end
    else
      logs = BalanceLog.where(account_public_id: account.public_id).limit(30)
      tasks = Task.where(public_id: logs.map { |log| log.metadata[:task_public_id] })
      result[:balance] = current_acount.balance
      result[:audit_log] = logs
      result[:tasks] = tasks
    end

    render json: result
  end
end