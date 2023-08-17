# frozen_string_literal: true

# Example consumer that prints messages payloads
class TasksConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      payload = message.payload
      case [payload['event_name'], payload['event_version']]
      when ['TaskCreated', 2]
        Task.create(
          public_id: payload['data']['public_id'],
          account_public_id: payload['data']['account_public_id'],
          description: payload['data']['description'],
          status: payload['data']['status'],
          fee: payload['data']['fee'],
          price: payload['data']['price']
        )
      when ['TaskUpdated', 1]
        Task.find_by!(public_id: payload['data']['public_id'])
         .update(
           account_public_id: payload['data']['account_public_id'],
           description: payload['data']['description'],
           status: payload['data']['status'],
           fee: payload['data']['fee'],
           price: payload['data']['price']
        )
      when ['TaskDeleted', 1]
        Task.destroy_by(public_id: payload['data']['public_id'])
      when ['TaskAssigned', 1]
        ActiveRecord.transaction do
          cycle = BillingCycle.find_or_create_by(account_public_id: payload['data']['account_public_id'], end_time: nil) do |record|
            record.start_time = Time.current
          end
          BalanceLog.create(
            billing_cycle_id: cycle.id,
            account_public_id: payload['data']['account_public_id'],
            log_type: 'TaskAssigned',
            description: 'Debit for assign task',
            debit: -payload['data']['fee'],
            metadata: {
              task_public_id: payload['data']['public_id']
            }
          )

          Account.lock("FOR UPDATE").where(public_id: payload['data']['account_public_id']).update('balance += ?', payload['data']['fee'])
        end
      when ['TaskCompleted', 1]
        ActiveRecord.transaction do
          Task.where(public_id: payload['data']['public_id'], )
          cycle = BillingCycle.find_or_create_by(account_public_id: payload['data']['account_public_id'], end_time: nil) do |record|
            record.start_time = Time.current
          end
          BalanceLog.create(
            billing_cycle_id: cycle.id,
            account_public_id: payload['data']['account_public_id'],
            log_type: 'TaskCompleted',
            description: 'Credit for assign task',
            credit: -payload['data']['price'],
            metadata: {
              task_public_id: payload['data']['public_id']
            }
          )

          Account.lock("FOR UPDATE").where(public_id: payload['data']['account_public_id']).update('balance += ?', payload['data']['price'])
        end
      end
      mark_as_consumed(message)
    end
  end
end
