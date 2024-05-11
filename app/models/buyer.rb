class Buyer < ApplicationRecord
  include ProtectDestroyable
  include ImageUploadable

  attr_accessor :debt_in_usd
  attr_accessor :debt_in_uzs

  geocoded_by :address
  belongs_to :agent_user, class_name: "User"
  belongs_to :diller_user, class_name: "User"
  validates_presence_of :name
  validates_uniqueness_of :name
  has_many_attached :images
  has_many :sales
  has_many :sale_from_local_services
  has_many :sale_from_services
  scope :active, -> { where(:active => true) }
  after_create :set_debt
  validate :valid_roles

  def calculate_debt_in_usd
    self.sales.price_in_usd.sum(:total_price) - self.sales.price_in_usd.sum(:total_paid)
  end

  def calculate_debt_in_uzs
    self.sales.price_in_uzs.sum(:total_price) - self.sales.price_in_uzs.sum(:total_paid)
  end

  private


  def valid_roles
    unless agent_user&.агент?
      errors.add(:agent_user, "must be an agent")
    end

    unless diller_user&.диллер?
      errors.add(:diller_user, "must be a diller")
    end
  end

  def set_debt
    unless debt_in_usd.empty?
      Sale.create(
        user_id: User.first.id, status: 1,
        payment_type: 0, total_price: debt_in_usd.to_f,
        total_paid: 0, buyer_id: id,
        price_in_usd: true
      )
    end

    unless debt_in_uzs.empty?
      Sale.create(
        user_id: User.first.id, status: 1,
        payment_type: 0, total_price: debt_in_uzs.to_f,
        total_paid: 0, buyer_id: id,
        price_in_usd: false
      )
    end
  end
end
