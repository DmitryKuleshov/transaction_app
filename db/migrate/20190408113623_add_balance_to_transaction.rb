class AddBalanceToTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :balance, :float
  end
end
