class AddAgentAndDillerReferencesToBuyers < ActiveRecord::Migration[7.0]
  def change
    add_reference :buyers, :agent_user, foreign_key: { to_table: :users }
    add_reference :buyers, :diller_user, foreign_key: { to_table: :users }
    add_column :buyers, :address, :string
  end
end
