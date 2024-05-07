require "telegram/bot"

# app/jobs/send_message_job.rb
class SendMessageJob < ApplicationJob
  queue_as :default

  def perform(message, chat = 'tech')
    token = ENV["TELEGRAM_TOKEN"]
    bot = Telegram::Bot::Client.new(token)
    chat_id =
      case chat
      when 'tech'
        ENV["TELEGRAM_CHAT_ID"]
      when 'warning'
        ENV["TELEGRAM_WARNING_CHAT_ID"]
      when 'report'
        ENV["TELEGRAM_REPORT_CHAT_ID"]
      when 'agent'
        ENV["TELEGRAM_AGENT_CHAT_ID"]
      end
    begin
      bot.api.send_message(
        chat_id: chat_id,
        text: message,
        parse_mode: "HTML",
        disable_web_page_preview: 1
      )
    rescue => exception
      puts "error"
    end
  end
end
