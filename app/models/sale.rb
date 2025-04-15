class Sale < ApplicationRecord
  include ProductSellHelper
  include ImageUploadable
  attr_accessor :discount_price
  belongs_to :buyer
  belongs_to :user
  belongs_to :agent_user, class_name: "User"
  belongs_to :diller_user, class_name: "User"
  enum status: %i[processing verified_by_agent verified_by_diller closed]
  enum payment_type: %i[наличные карта click предоплата перечисление дригие]
  has_many :product_sells
  has_one :discount
  # has_one :diller, class_name: 'User', through: :buyer
  has_many :transaction_histories, dependent: :destroy
  has_many_attached :images
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

  def show_sale_via_qr_code_svg
    qr = RQRCode::QRCode.new("#{ENV.fetch('HOST_URL')}/sales/#{id}")
    qr.as_svg(
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 1.9,
      standalone: true,
      use_path: true
    )
  end


  private

  def process_status_change
    if verified_by_agent? && status_before_last_save != 'verified_by_agent'
      price_sign = price_in_usd ? '$' : 'сум'
      message =
        "Новый заказ от агента <b>#{user.name}</b>\n" \
        "<b>Клиент</b>: #{buyer.name}\n" \
        "<b>Агент</b>: #{diller_user.name}\n\n"
      message << "-------------------------\n"
      product_sells.each do |product_sell|
        message << "#{product_sell.pack.name}: #{amount_in_string(product_sell.pack.name, product_sell.amount, product_sell.pack.amount_per_pack)}\n\n"
      end
      message << "-------------------------\n\n"

      message << "<b>Итого цена:</b> #{ActionController::Base.helpers.number_to_currency(total_price, unit: '', precison: 0)} #{price_sign}\n"
      SendMessageJob.perform_later(message, 'agent')
    elsif closed? && status_before_last_save != 'closed'
      return unless enable_to_send_sms

      message =
        "Поступление денег\n" \
        "<b>Диллер:</b>: #{user.name}\n" \
        "<b>Покупатель:</b>: #{buyer.name}\n" \
        "<b>Цена заказа:</b>: #{total_price}\n" \
        "<b>Оплачено:</b>: #{total_paid}\n" \
        "<a href=\"#{ENV.fetch('HOST_URL')}/sales/#{id}\">Посмотреть</a>"
      SendMessageJob.perform_later(message)
      self.enable_to_send_sms = false
    end
  end

  def update_product_sales_currencies
    return if product_sells.empty? || ENV.fetch('ONLY_ONE_CURRENCY')

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
    SendMessageJob.perform_later(message, 'agent')
  end
end
