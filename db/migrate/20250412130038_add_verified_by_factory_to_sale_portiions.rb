class AddVerifiedByFactoryToSalePortiions < ActiveRecord::Migration[7.0]
  def change
    add_column :sale_portions, :verified_by_factory, :boolean, default: false
  end
end
