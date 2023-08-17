class Account < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :access_grants,
           class_name: 'Doorkeeper::AccessGrant',
           foreign_key: :resource_owner_id,
           dependent: :delete_all # or :destroy if you need callbacks

  has_many :access_tokens,
           class_name: 'Doorkeeper::AccessToken',
           foreign_key: :resource_owner_id,
           dependent: :delete_all # or :destroy if you need callbacks

  enum :role, ['worker', 'bookkeeper', 'manager', 'admin'].index_by(&:itself), prefix: true, default: 'worker'

  after_create do
    record = self

    event = {
      event_name: 'AccountCreated', # Не увидел никакого смысла изменять названия. С одинаковыми названиями нам будет проще общаться
      data: record.slice(:public_id, :role, :email)
    }

    Karafka.producer.produce_sync(topic: 'accounts-stream', payload: event.to_json)
  end

  after_update do
    record = self

    event = {
      event_name: 'AccountUpdated',
      data: record.slice(:public_id, :role, :email)
    }

    Karafka.producer.produce_sync(topic: 'accounts-stream', payload: event.to_json)

    if role_changed?
      event = {
        event_name: 'AccountRoleChanged',
        data: { **record.slice(:public_id, :role), old_role: role_was }
      }

      Karafka.producer.produce_sync(topic: 'accounts-be', payload: event.to_json)
    end
  end

  after_destroy do
    record = self

    event = {
      event_name: 'AccountDeleted',
      data: record.slice(:public_id)
    }

    Karafka.producer.produce_sync(topic: 'accounts-stream', payload: event.to_json)
  end
end
