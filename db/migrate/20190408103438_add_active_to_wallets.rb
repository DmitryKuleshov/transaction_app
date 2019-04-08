class AddActiveToWallets < ActiveRecord::Migration[5.2]
  def change
    add_column :wallets, :active, :boolean, default: false
  end
end
