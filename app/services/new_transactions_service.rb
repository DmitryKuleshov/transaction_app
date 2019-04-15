class NewTransactionsService
  def initialize(params, current_user)
    @current_user = current_user
    @to_wallet = User.find(params[:transaction][:to_user_id]).bank_account.wallets.where(currency_id: params[:transaction][:currency_id]).first
    @to_wallet_id = @to_wallet.id
    @to_currency_id = params[:transaction][:currency_id].to_i
    @to_currency_abbr = Currency.find(@to_currency_id).abbreviation
    @value = Money.new(params[:transaction][:value].to_i, @to_currency_abbr)
    @subtransactions = []
    @wallets = @current_user.bank_account.wallets

    add_rates
  end

  def call
    balance = @wallets.sum do |wallet|
      Money.new(wallet.balance, wallet.currency.abbreviation).exchange_to(@to_currency_abbr)
    end

    if balance < @value
      return false
    end

    wallets_sort

    iterator = 0
    while @value > 0 do
      from_currency_abbr = @wallets[iterator].currency.abbreviation

      wallet_balance = Money.new(@wallets[iterator].balance, from_currency_abbr).exchange_to(@to_currency_abbr)
      result = @value - wallet_balance
      if result > 0
        if iterator == 0
          @transaction = Transaction.new(to_wallet_id: @to_wallet_id, balance: @value.fractional)
          @to_wallet.balance += @value.fractional
        end
        @value = result
        @subtransactions.push(Transaction.new(from_wallet_id: @wallets[iterator].id, balance: @wallets[iterator].balance, parent_id: @transaction))
        @wallets[iterator].balance = 0
      else
        @wallets[iterator].balance = result.fractional.abs / get_rate(from_currency_abbr, @to_currency_abbr)
        if @subtransactions.empty?
          @transaction = Transaction.new(to_wallet_id: @to_wallet_id, from_wallet_id: @wallets[iterator].id, balance: @value.fractional)
          @to_wallet.balance += @value.fractional
        else
          @subtransactions.push(Transaction.new(from_wallet_id: @wallets[iterator].id, balance: @value.fractional, parent_id: @transaction))
        end

        @value = 0
      end
      iterator = iterator + 1
    end

    [@transaction, @subtransactions, @wallets, @to_wallet]
  end

  def add_rates
    @wallets.each do |wallet|
      if wallet.currency.abbreviation == @to_currency_abbr
        Money.add_rate(@to_currency_abbr, @to_currency_abbr, 1)
      else
        Money.add_rate(wallet.currency.abbreviation, @to_currency_abbr, rand(0.1...2).round(3))
      end
    end
  end

  def wallets_sort
    @wallets = @wallets.sort_by do |wallet|
      Money.new(wallet.balance, wallet.currency.abbreviation).exchange_to(@to_currency_abbr)
    end

    index = @wallets.index{|wallet| wallet.currency_id==@to_currency_id}
    if index
      @wallets.insert(0, @wallets.delete_at(index))
    end
  end

  def get_rate(from, to)
    Money.new(1, from).exchange_to(to).fractional
  end
end
