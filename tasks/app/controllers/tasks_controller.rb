class TasksController < ApplicationController
  def index
    render json: Task.where(account_public_id: current_account.public_id).all
  end

  def create
    task = Task.create!(
      description: params[:description],
      status: :in_progress,
      account_public_id: current_account.public_id,
      fee: rand(-20..-10),
      price: rand(20..40)
    )

    event = {
      event_name: 'TaskAssigned',
      data: {
        public_id: task.public_id,
        account_public_id: current_account.public_id,
        fee: task.fee,
        assigned_at: Time.current
      }
    }

    Karafka.producer.produce_sync(topic: 'tasks-be', payload: event.to_json)
  end

  def complete
    task = Task.find_by(public_id: params[:public_id])
    task.update!(status: :completed)

    event = {
      event_name: 'TaskCompleted',
      data: {
        public_id: task.public_id,
        price: task.price,
        completed_at: Time.current
      }
    }

    Karafka.producer.produce_sync(topic: 'tasks-be', payload: event.to_json)
  end

  def reassign
    tasks = Task.where.not(status: :completed).all
    accounts = Account.where.not(role: [:manager, :admin]).all
    time = Time.current
    assigns = tasks.map do |task|
      pid = accounts[rand(0...accounts.count)].public_id
      task.update(account_public_id: pid)

      {
        public_id: task.public_id,
        account_public_id: pid,
        fee: task.fee,
        assigned_at: time
      }
    end

    assigns.each_slice(100) do |slice|
      event = {
        event_name: 'TaskAssigned',
        data: slice
      }

      Karafka.producer.produce_sync(topic: 'tasks-be', payload: event.to_json)
    end
  end
end