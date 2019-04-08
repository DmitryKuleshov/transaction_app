class AddWalletRefToTransaction < ActiveRecord::Migration[5.2]
  def change
    add_reference :transactions, :wallet, foreign_key: true

    add_column :transactions, :from_wallet_id, :integer
    add_column :transactions, :to_wallet_id, :integer
  end
end
