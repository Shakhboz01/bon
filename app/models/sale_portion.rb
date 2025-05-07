class SalePortion < ApplicationRecord
  belongs_to :user, optional: true
  validates :till, presence: true
  before_create :set_default_values
  before_create :send_notify

  scope :sales, ->(from, till) {
    Sale.where('sales.created_at BETWEEN ? AND ?', from, till)
  }

  def self.find_from_attribute
    previous_record = SalePortion.order(created_at: :desc).first
    # set from datetime attribute based on previous set datetime attribute, if previous not exists: set it to the earliest creted_at attribute of Sale record
    if previous_record
      previous_record.till
    else
      earliest_sale = Sale.order(:created_at).first
      if earliest_sale
        earliest_sale.created_at
      else
        till || Time.current
      end
    end
  end

  private

  def set_default_values
    sales = SalePortion.sales(from, till)
    self.total_price = sales.sum(:total_price)
    sales.update_all(status: :verified_by_diller)
  end

  def send_notify

  end
end
