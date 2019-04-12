class Wallet < ApplicationRecord
  belongs_to :bank_account
  belongs_to :currency
end
