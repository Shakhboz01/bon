class SalePortion < ApplicationRecord
  belongs_to :user
  validates :till, presence: true
  after_initialize :set_from_attribute
  before_create :set_default_values
  before_create :send_notify

  scopre :sales, ->(from, till) {
    Sale.where('created_at BETWEEN ? AND ?', from, till)
  }

  private

  def set_from_attribute
    previous_record = SalePortion.order(created_at: :desc).first
    # set from datetime attribute based on previous set datetime attribute, if previous not exists: set it to the earliest creted_at attribute of Sale record
    if previous_record
      self.from = previous_record.till
    else
      earliest_sale = Sale.order(:created_at).first
      if earliest_sale
        self.from = earliest_sale.created_at
      else
        self.from = till
      end
    end
  end

  def set_default_values
    self.total_price = SalePortion.sales(from, till).sum(:total_price)
    sales.update_all(status: :verified_by_diller)
  end

  def send_notify

  end
end
