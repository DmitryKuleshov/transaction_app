class AddCurrencyRefToBankAccount < ActiveRecord::Migration[5.2]
  def change
    add_reference :bank_accounts, :currency, foreign_key: true
  end
end
