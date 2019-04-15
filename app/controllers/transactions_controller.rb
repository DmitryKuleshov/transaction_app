class TransactionsController < ApplicationController
  before_action :authenticate_user!

  def index
    wallet_ids = current_user.bank_account.wallets.pluck(:id)
    @transactions = Transaction.where("to_wallet_id IN (?) OR from_wallet_id IN (?)", wallet_ids, wallet_ids)
    @balance = 10
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
    result = NewTransactionsService.new(params, current_user).call

    @transaction = result[0]
    @subtransactions = result[1]
    @wallets = result[2]
    @to_wallet = result[3]

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

  def start_transaction
    ActiveRecord::Base.transaction do
      if @transaction
        @transaction.save!
      else
        return false
      end
      if !@subtransactions.empty?
        @subtransactions.each {|subtransaction| subtransaction.save! }
      end
      if @wallets
        @wallets.each {|wallet| wallet.save! }
      else
        return false
      end

      if @to_wallet
        @to_wallet.save!
      else
        return false
      end
    end
  end
end
