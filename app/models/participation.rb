class Participation < ApplicationRecord
  belongs_to :user
  enum status: %i[пришёл не_пришёл выходной]

  scope :allowed, lambda {
    where('created_at > ?', Date.current.beginning_of_day)
  }

  after_create :send_notify

  private

  def send_notify
    return unless не_пришёл?

    message = "&#9888 #{user.name.upcase} не пришел на работу"
    SendMessageJob.perform_later(message, 'warning')
  end
end
