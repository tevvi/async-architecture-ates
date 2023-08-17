# frozen_string_literal: true

# Example consumer that prints messages payloads
class AccountsConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      payload = message.payload
      case payload['event_name']
      when 'AccountCreated'
        Account.create(
          public_id: payload['data']['public_id'],
          role: payload['data']['role'],
          email: payload['data']['email']
        )
      when 'AccountUpdated'
        Account.find_by!(public_id: payload['data']['public_id'])
               .update(
          role: payload['data']['role'],
          email: payload['data']['email']
        )
      when 'AccountDeleted'
        Account.destroy_by(public_id: payload['data']['public_id'])
      when 'AccountRoleChanged'
        # TODO: reassign tasks if role changed from admin/to admin or something like it
      end
      mark_as_consumed(message)
    end
  end
end
