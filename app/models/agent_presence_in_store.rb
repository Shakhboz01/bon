class AgentPresenceInStore < ApplicationRecord
  belongs_to :user
  belongs_to :buyer

  enum status: %i[с_заказом без_заказа]
  enum danger_status: %i[до_50_метр до_150_метр от_150_метр]

  before_create :set_danger_status

  private


  def set_danger_status
    if distance_in_meters <= 50
      self.status = 0
    elsif distance_in_meters <= 150
      self.status = 1
    else
      2
    end
  end
end
