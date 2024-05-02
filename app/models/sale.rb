class Sale < ApplicationRecord
  include HandleTransactionHistory
  include ApplicationHelper
  attr_accessor :discount_price
  belongs_to :buyer
  belongs_to :user
  belongs_to :agent, class_name: 'User',
                    foreign_key: 'agent_user_id', optional: true
  enum status: %i[processing closed]
  enum payment_type: %i[наличные карта click предоплата перечисление дригие]
  has_many :product_sells
  has_one :discount
  has_many :transaction_histories, dependent: :destroy
  scope :unpaid, -> { where("total_price > total_paid") }
  scope :price_in_uzs, -> { where('price_in_usd = ?', false) }
  scope :price_in_usd, -> { where('price_in_usd = ?', true) }
  scope :filter_by_total_paid_less_than_price, ->(value) {
          if value == "1"
            where("total_paid < total_price")
          else
            all
          end
        }
  before_update :update_product_sales_currencies
  before_update :send_notify_if_verified_by_agent
  after_save :process_status_change, if: :saved_change_to_status?

  def calculate_total_price(enable_to_alter = true)
    total_price = 0
    self.product_sells.each do |product_sell|
      total_price += product_sell.amount * product_sell.sell_price
    end

    if enable_to_alter
      self.total_price = total_price unless closed?
    end

    total_price
  end

  def total_profit
    product_sells.sum(:total_profit)
  end


  private

  def process_status_change
    if closed? && status_before_last_save != 'closed'
      if enable_to_send_sms
        price_sign = price_in_usd ? '$' : 'сум'
        message =  "Sotuv amalga oshirildi\n" \
          "<b>Mijoz</b>: #{buyer.name}\n" \
          "<b>To'lov turi</b>: #{payment_type}\n" \
          "<b>Jami narx:</b> #{total_price} #{price_sign}\n"
        message << "&#9888<b>To'landi:</b> #{total_paid} #{price_sign}\n" if total_price != total_paid
        message << "<b>Комментарие:</b> #{comment}\n" if comment.present?
        message << "<b>Mijoz qarzdorligi:</b> #{buyer.calculate_debt_in_uzs}\n"
        SendMessage.run(message: message)
      else
        self.enable_to_send_sms = false
      end
    end
  end

  def update_product_sales_currencies
    return if product_sells.empty?

    product_sells.each do |ps|
      ps.price_in_usd = price_in_usd
      ps.save!
    end

    self.total_price = product_sells.sum(('sell_price * amount'))
  end

  def send_notify_if_verified_by_agent
    return if verified_by_agent == verified_by_agent_was

    message = "Агент оформил заказ от #{buyer.name}\n" \
              "<a href=\"#{ENV.fetch('HOST_URL')}/sales/#{id}\">Посмотреть</a>"
    SendMessage.run(message: message, chat: 'agent')
  end
end
