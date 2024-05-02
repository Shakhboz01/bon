require "telegram/bot"

class SendMessage < ActiveInteraction::Base
  string :message
  string :chat, default: 'tech'

  def execute
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
        chat_id: ENV["TELEGRAM_CHAT_ID"],
        text: message,
        parse_mode: "HTML",
        disable_web_page_preview: 1
      )

    rescue => exception
      puts "error"
    end
  end
end
