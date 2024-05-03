class AddWeightToPacks < ActiveRecord::Migration[7.0]
  def change
    add_column :packs, :weight, :integer, default: 0
  end
end
