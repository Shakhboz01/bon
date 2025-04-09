class CreateSalePortions < ActiveRecord::Migration[7.0]
  def change
    create_table :sale_portions do |t|
      t.datetime :from
      t.datetime :till
      t.references :user, null: false, foreign_key: true
      t.decimal :total_price, precision: 10, scale: 2

      t.timestamps
    end
  end
end
