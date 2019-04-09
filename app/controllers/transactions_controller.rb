class TransactionsController < ApplicationController
  before_action :authenticate_user!

  def index
    to_wallet_ids = current_user.bank_account.wallets.pluck(:id)
    @transactions = Transaction.where(to_wallet_id: to_wallet_ids)
  end
end
