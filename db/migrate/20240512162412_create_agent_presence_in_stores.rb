class CreateAgentPresenceInStores < ActiveRecord::Migration[7.0]
  def change
    create_table :agent_presence_in_stores do |t|
      t.references :user, null: false, foreign_key: true
      t.references :buyer, null: false, foreign_key: true
      t.float :latitude
      t.float :longitude
      t.integer :status, default: 0 # order_placed order_not_placed
      t.integer :danger_status, default: 0 # near away far_away
      t.decimal :distance_in_meters, precision: 15, scale: 2

      t.timestamps
    end
  end
end
