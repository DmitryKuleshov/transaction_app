class Wallet < ApplicationRecord
  belongs_to :bank_account
  belongs_to :currency

  def get_user
    bank_account.user
  end
end
