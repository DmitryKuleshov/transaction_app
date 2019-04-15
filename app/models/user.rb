class User < ApplicationRecord
  belongs_to :country
  has_one :bank_account, dependent: :destroy

  after_create :add_money

  devise :database_authenticatable, :registerable,
         :rememberable, :validatable

  private
  def add_money
    currency = Currency.find_by_abbreviation(ISO3166::Country.new(country.iso).currency_code)

    BankAccount.create(user_id: self.id, currency_id: currency.id)

    Money.add_rate("USD", currency.abbreviation, rand(0.1...2).round(3))
    balance = Money.us_dollar(1000).exchange_to(currency.abbreviation).fractional

    wallet = Wallet.create(currency_id: currency.id, active: true, bank_account_id: bank_account, balance: balance)

    Transaction.create(to_wallet_id: wallet.id, balance: balance)
  end
end
