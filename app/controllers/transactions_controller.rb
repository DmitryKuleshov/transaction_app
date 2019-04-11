class TransactionsController < ApplicationController
  before_action :authenticate_user!

  def index
    wallet_ids = current_user.bank_account.wallets.pluck(:id)
    @transactions = Transaction.where("to_wallet_id = ? OR from_wallet_id = ?", wallet_ids, wallet_ids)
  end
end
