class RemoveProviderFromDelivery < ActiveRecord::Migration[7.0]
  def change
    remove_column :delivery_from_counterparties, :provider_id
  end
end
