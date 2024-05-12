class DeliveryProviderNull < ActiveRecord::Migration[7.0]
  def change
    change_column :delivery_from_counterparties, :provider_id, :bigint, null: true
  end
end
