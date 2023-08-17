# frozen_string_literal: true

class KarafkaApp < Karafka::App
  setup do |config|
    config.kafka = { 'bootstrap.servers': 'kafka:9092' }
    config.client_id = 'example_app'

    # Recreate consumers with each batch. This will allow Rails code reload to work in the
    # development mode. Otherwise Karafka process would not be aware of code changes
    config.consumer_persistence = !Rails.env.development?
  end

  # Comment out this part if you are not using instrumentation and/or you are not
  # interested in logging events for certain environments. Since instrumentation
  # notifications add extra boilerplate, if you want to achieve max performance,
  # listen to only what you really need for given environment.
  Karafka.monitor.subscribe(Karafka::Instrumentation::LoggerListener.new)
  # Karafka.monitor.subscribe(Karafka::Instrumentation::ProctitleListener.new)

  # This logger prints the producer development info using the Karafka logger.
  # It is similar to the consumer logger listener but producer oriented.
  Karafka.producer.monitor.subscribe(
    WaterDrop::Instrumentation::LoggerListener.new(Karafka.logger)
  )

  routes.draw do
    # Uncomment this if you use Karafka with ActiveJob
    # You need to define the topic per each queue name you use
    # active_job_topic :default

    topic :'accounts-cud' do
      config(partitions: 2, 'cleanup.policy': 'compact')
      consumer AccountsConsumer
    end

    topic :'accounts-be' do
      config(partitions: 2, 'cleanup.policy': 'compact')
      consumer AccountsConsumer
    end

    topic :'tasks-lifecycle' do
      config(partitions: 2, 'cleanup.policy': 'compact')
      consumer TasksConsumer
    end

    topic :'tasks-stream' do
      config(partitions: 2, 'cleanup.policy': 'compact')
      consumer TasksConsumer
    end

    topic :'balance-lifecycle' do
      config(partitions: 2, 'cleanup.policy': 'compact')
      consumer BalanceConsumer
    end
  end
end

Karafka::Web.enable!