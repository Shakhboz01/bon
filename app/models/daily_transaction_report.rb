class DailyTransactionReport < ApplicationRecord
  belongs_to :user

  validate :unique_report_per_day
  after_create :send_message

  private

  def unique_report_per_day
    if DailyTransactionReport.exists?(created_at: created_at.beginning_of_day..created_at.end_of_day)
      errors.add(:base, "Ежедневный отчет о транзакциях уже существует за этот день.")
    end
  end

  def send_message
    message =
      "<b>Отчет по кассе:</b>\n" \
      "по данным #{created_at.to_date}, на кассе имеется #{income_in_uzs}сум + #{income_in_usd}$"
    SendMessageJob.perform_later(message)
  end
end
