# frozen_string_literal: true

task :pay_salary, [:task_name] => :environment do |_task, args|
  cycles = BillingCycle.where(end_time: nil, account_public_id: Account.where('balance > 0').select(:id))
  BillingCycle.where(id: cycles.ids).update_all(end_time: Time.current)

  cycles.each do |cycle|
    logs = BillingLog.where(billing_cycle_id: cycle.id)
    debit = logs.sum(:credit) - logs.sum(:debit)
    BalanceLog.create(
      billing_cycle_id: cycle.id,
      account_public_id: cycle.account_public_id,
      log_type: 'PaySalary',
      description: 'Daily pay salary',
      debit: debit
    )
    # Вдруг за то время пока мы возимся баланс пользователя обновится, надежнее отнять от текущего значения
    Account.lock("FOR UPDATE").where(public_id: cycle.account_public_id).update('balance -= ?', debit)

    event = {
      event_name: 'DailySalaryPaid',
      data: {
        account_public_id: cycle.account_public_id,
        amount: debit
      }
    }

    Karafka.producer.produce_sync(topic: 'balance-lifecycle', payload: event.to_json)
  end
end
