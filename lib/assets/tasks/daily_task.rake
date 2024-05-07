namespace :daily_task do
  task send_message: :environment do
    SendMessageJob.perform_later('Hello world')
  end
end
