class AddFieldsToSale < ActiveRecord::Migration[7.0]
  def change
    add_column :sales, :verified_by_agent, :boolean, default: false
    add_column :sales, :diller_user_id, :bigint
  end
end
