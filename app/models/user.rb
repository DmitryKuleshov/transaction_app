class User < ApplicationRecord
  belongs_to :country
  has_one :bank_account, dependent: :destroy

  after_save :create_banck_account

  devise :database_authenticatable, :registerable,
         :rememberable, :validatable

  private
  def create_banck_account
    currency_code = ISO3166::Country.new(self.country.iso).currency_code
    currency_id = Currency.find_by_abbreviation(currency_code).id

    BankAccount.create(user_id: self.id, currency_id: currency_id)
    create_wallet(currency_code, currency_id)
  end

  def create_wallet(currency_code, currency_id)
    wallet = Wallet.create(currency_id: currency_id, active: true, bank_account_id: self.bank_account.id)

    create_initial_transaction(wallet, currency_code)
  end

  def create_initial_transaction(wallet, currency_code)
    #add rate hardcoded for now
    #need to add rates bettween all currencies
    Money.add_rate("USD", currency_code, 1.24515)
    balance = Money.us_dollar(1000).exchange_to(currency_code)

    Transaction.create(to_wallet_id: wallet.id, balance: balance)
    wallet.update(balance: balance)
  end
end
