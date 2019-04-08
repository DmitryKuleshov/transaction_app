class Transaction < ApplicationRecord
  belongs_to :fromWallet, class_name: 'Wallet', foreign_key: :from_wallet_id, optional: true
  belongs_to :toWallet, class_name: 'Wallet', foreign_key: :to_wallet_id, optional: true
end
