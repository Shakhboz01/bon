class MakeNullTrue < ActiveRecord::Migration[7.0]
  def change
    change_column_null :sale_portions, :user_id, true
  end
end
