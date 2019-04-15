class RemoveWalletIdFromTransactions < ActiveRecord::Migration[5.2]
  def change
    remove_column :transactions, :wallet_id, :bigint
  end
end
