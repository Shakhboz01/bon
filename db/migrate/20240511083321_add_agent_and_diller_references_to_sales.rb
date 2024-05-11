class AddAgentAndDillerReferencesToSales < ActiveRecord::Migration[7.0]
  def change
    remove_column :sales, :diller_user_id
    add_reference :sales, :agent_user, foreign_key: { to_table: :users }
    add_reference :sales, :diller_user, foreign_key: { to_table: :users }
  end
end
