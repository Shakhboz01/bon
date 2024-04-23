class AddLatitudeAndLongitudeToBuyers < ActiveRecord::Migration[7.0]
  def change
    add_column :buyers, :latitude, :float
    add_column :buyers, :longitude, :float
  end
end
