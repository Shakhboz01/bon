class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :participations
  enum role: %i[админ менеджер агент диллер сотрудник складчик]
  validates :name, uniqueness: true

  scope :active, -> { where(:active => true) }

  def self.devise_parameter_sanitizer
    super.tap do |sanitizer|
      sanitizer.permit(:sign_up, keys: [:name])
    end
  end

  def active_for_authentication?
    super && allowed_to_use?
  end
end
