# frozen_string_literal: true

# Example consumer that prints messages payloads
class BalanceConsumer < ApplicationConsumer
  def consume
    messages.each do |message|
      payload = message.payload
      case payload['event_name']
      when 'DailySalaryPaid'
        account = Account.find_by(public_id: payload['data']['account_public_id'])
        # Вообще это нужно разбить на два независимых выполнения. Что бы если отвалилась платежка - эмейл все равно отправился.
        # И так же необходимо прослушивать батчами и через несколько тредов, или даже потоков, выполнять платежки,
        # так как палтежный провайдер может быть узким местом. Но это все нужно делать после того кодга хотя бы так взлетит в проде
        PaymentProvider.pay(account.payment_provider_credentials, payload['data']['amount'], retries: 10)
        Mailer.perform_async(account.email, MailView.render(:daily_selary_paid, account, payload['data']['amount']), retries: 3)
      end
      mark_as_consumed(message)
    end
  end
end
