class BankAccount < ApplicationRecord
  belongs_to :user
  has_many :wallets, dependent: :destroy
end
