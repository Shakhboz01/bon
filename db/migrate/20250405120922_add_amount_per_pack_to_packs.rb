class AddAmountPerPackToPacks < ActiveRecord::Migration[7.0]
  def change
    add_column :packs, :amount_per_pack, :integer
  end
end
