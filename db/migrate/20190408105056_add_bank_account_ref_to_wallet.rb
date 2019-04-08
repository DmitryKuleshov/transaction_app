class AddBankAccountRefToWallet < ActiveRecord::Migration[5.2]
  def change
    add_reference :wallets, :bank_account, foreign_key: true
  end
end
