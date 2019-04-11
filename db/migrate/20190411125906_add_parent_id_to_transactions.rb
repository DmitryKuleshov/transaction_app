class AddParentIdToTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :parent_id, :integer
  end
end
