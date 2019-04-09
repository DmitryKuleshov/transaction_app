class AddCurrencyRefToWallet < ActiveRecord::Migration[5.2]
  def change
    add_reference :wallets, :currency, foreign_key: true
  end
end
