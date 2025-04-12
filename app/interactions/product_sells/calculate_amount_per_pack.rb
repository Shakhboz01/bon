module ProductSells
  class CalculateAmountPerPack < ActiveInteraction::Base
    string :pack_name, default: nil
    integer :amount, default: nil
    integer :amount_per_pack, default: nil

    def execute
      return '' unless amount

      self.amount_per_pack ||= Pack.find_by(name: pack_name)&.amount_per_pack if pack_name.present?
      if amount < amount_per_pack
        return "#{amount} ШТУК"
      end

      amount_in_box = (amount / amount_per_pack).to_i
      remaining = (amount % amount_per_pack).to_i

      if remaining.zero?
        "#{amount_in_box} упаковки"
      else
        "#{amount_in_box} УПАКОВКА И #{remaining} ШТУК"
      end
    end
  end
end