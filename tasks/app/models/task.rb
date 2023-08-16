class Task < ApplicationRecord
  enum :status, ['in_progress', 'completed'].index_by(&:itself), prefix: true, default: 'in_progress'

  after_create do
    record = self

    event = {
      event_name: 'TaskCreated',
      data: record.slice(:public_id, :account_public_id, :description, :status, :fee, :price)
    }

    Karafka.producer.produce_sync(topic: 'tasks-cud', payload: event.to_json)
  end

  after_update do
    record = self

    event = {
      event_name: 'TaskUpdated',
      data: record.slice(:public_id, :account_public_id, :description, :status, :fee, :price)
    }

    Karafka.producer.produce_sync(topic: 'tasks-cud', payload: event.to_json)
  end

  after_destroy do
    record = self

    event = {
      event_name: 'TaskDeleted',
      data: record.slice(:public_id)
    }

    Karafka.producer.produce_sync(topic: 'tasks-cud', payload: event.to_json)
  end
end
