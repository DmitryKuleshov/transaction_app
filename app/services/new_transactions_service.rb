class NewTransactionsService
  attr_accessor :to_wallet, :value, :wallets, :transaction, :subtransactions, :wallets_with_value, :to_currency

  def initialize(params, current_user)
    @to_wallet = User.find(params[:to_user_id]).bank_account.wallets.find_by(currency_id: params[:currency_id])
    @to_currency = @to_wallet.currency
    @value = Money.new(params[:value].to_i, @to_currency.abbreviation)
    @subtransactions = []
    @wallets = current_user.bank_account.wallets

    add_rates
    set_wallets_value
  end

  def call
    balance = wallets.sum {|wallet| wallet[:value]}

    if balance < value
      return {error: 'insufficient funds'}
    end

    wallets_sort
    wallets_handler

    {
      transaction: transaction,
      subtransactions: subtransactions,
      wallets: wallets.map{|x| x[:wallet]},
      to_wallet: to_wallet
    }
  end

  def add_rates
    wallets.each do |wallet|
      if wallet.currency.abbreviation == to_currency.abbreviation
        Money.add_rate(to_currency.abbreviation, to_currency.abbreviation, 1)
      else
        Money.add_rate(wallet.currency.abbreviation, to_currency.abbreviation, rand(1.2...2).round(3))
      end
    end
  end

  def set_wallets_value
    @wallets = wallets.map do |wallet|
      {
        wallet: wallet,
        value: Money.new(wallet.balance, wallet.currency.abbreviation).exchange_to(to_currency.abbreviation)
      }
    end
  end

  def wallets_sort
    @wallets = @wallets.sort_by {|wallet| wallet[:value].fractional}

    index = @wallets.index{|wallet| wallet[:wallet].currency_id==to_currency.id}

    @wallets.insert(0, @wallets.delete_at(index)) if index
  end

  def wallets_handler
    wallets.each do |wallet|
      if wallet[:value].fractional > 0
        result = value - wallet[:value]

        if result.fractional > 0
          unless @transaction
            @transaction = new_transaction(nil, to_wallet.id, value.fractional)
            to_wallet.balance += value.fractional
          end
          subtransactions.push(new_transaction(wallet[:wallet].id, nil, wallet[:wallet].balance))
          wallet[:wallet].balance = 0
        else
          wallet[:wallet].balance = result.fractional.abs / get_rate(wallet[:wallet].currency.abbreviation, to_currency.abbreviation)

          if subtransactions.empty?
            @transaction = new_transaction(wallet[:wallet].id, to_wallet.id, @value.fractional)
            to_wallet.balance += @value.fractional
          else
            subtransactions.push(new_transaction(wallet[:wallet].id, nil, @value.fractional))
          end

          break
        end
      end
    end
  end

  def get_rate(from, to)
    Money.new(1, from).exchange_to(to).fractional
  end

  def new_transaction(from, to, balance)
    Transaction.new(from_wallet_id: from, to_wallet_id: to, balance: balance)
  end
end
