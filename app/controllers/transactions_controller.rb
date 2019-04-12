class TransactionsController < ApplicationController
  before_action :authenticate_user!

  def index
    wallet_ids = current_user.bank_account.wallets.pluck(:id)
    @transactions = Transaction.where("to_wallet_id = ? OR from_wallet_id = ?", wallet_ids, wallet_ids)
    @balance = @transactions.sum(&:balance)
  end

  def new
    if params[:filters]
      @user_id = params[:filters][:user_id]
      currency_ids = User.find(@user_id).bank_account.wallets.pluck(:currency_id).uniq
      @currencies = Currency.find(currency_ids)
      @transaction = Transaction.new
    end
  end

  def create
    @to_wallet_id = User.find(params[:transaction][:to_user_id]).bank_account.wallets.where(currency_id: params[:transaction][:currency_id]).first.id

    respond_to do |format|
      if start_transaction
        format.html { redirect_to transaction_path(@transaction.id), notice: 'Transaction was successfully created.' }
      else
        format.html { render :new }
      end
    end

  end

  def show
    set_transaction

    if !@transaction.from_wallet_id
      set_subtransactions
    elsif !@transaction.to_wallet_id
      set_transaction(@transaction.parent_id)
      set_subtransactions
    end
  end

  private
  def set_transaction(id = params[:id])
    @transaction = Transaction.find(id)
  end

  def set_subtransactions
    @subtransactions = Transaction.where(parent_id: @transaction.id)
  end

  #TODO
  #1) remove transactions logic to service
  #2) sort wallets before transactions

  def start_transaction
    #hardcoded rate
    Money.add_rate("CAD", "EUR", 0.8)

    value = params[:transaction][:value].to_i
    @wallets = current_user.bank_account.wallets
    balance = Transaction.where("to_wallet_id = ? OR from_wallet_id = ?", @wallets.ids, @wallets.ids).sum(&:balance)

    if balance > value
      ActiveRecord::Base.transaction do
        iterator = 0
        while value > 0 do
          result = value - @wallets[iterator].balance.to_i
          if result > 0
            if iterator == 0
              @transaction = Transaction.create(to_wallet_id: @to_wallet_id, balance: value)
            end
            @wallets[iterator].balance = 0
            value = result
            Transaction.create(from_wallet_id: @wallets[iterator].id, balance: @wallets[iterator].balance, parent_id: @transaction)
          else
            from = @wallets[iterator].currency.abbreviation
            to = Currency.find(params[:transaction][:currency_id]).abbreviation
            @wallets[iterator].balance = result.abs / get_rate(from, to)
            @transaction = Transaction.create(to_wallet_id: @to_wallet_id, from_wallet_id: @wallets[iterator].id, balance: value)
            value = 0
          end
          @wallets[iterator].save!
          iterator = iterator + 1
        end
      end
      return true
    else
      return false
    end
  end

  def wallets_sort
    @wallets = @wallets.sort_by {|wallet| convert(params[:transaction][:currency_id], wallet.currency_id, wallet.balance)}
  end

  def get_rate(from, to)
    Money.new(1, from).exchange_to(to).fractional
  end
end
