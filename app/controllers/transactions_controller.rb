class TransactionsController < ApplicationController
  before_action :authenticate_user!

  def index
    wallet_ids = current_user.bank_account.wallets.pluck(:id)
    @transactions = Transaction.where(to_wallet_id: wallet_ids).or(Transaction.where(from_wallet_id: wallet_ids))
  end

  def new
    if params[:filters]
      @user_id = params[:filters][:user_id]
      @currencies = User.find(@user_id).bank_account.wallets.collect(&:currency).uniq
      @transaction = Transaction.new
    end
  end

  def create
    @result = NewTransactionsService.new(transaction_params, current_user).call

    render_create
  end

  def show
    set_transaction(params[:id])
    p @transaction.to_wallet_id

    set_transaction(@transaction.parent_id) if !@transaction.to_wallet_id

    set_subtransactions
  end

  private

  def render_create
    if !@result[:error] && start_transaction
      redirect_to transaction_path(@result[:transaction]), notice: 'Transaction was successfully created.'
    else
      render :new
    end
  end

  def set_transaction(id)
    @transaction = Transaction.find(id)
  end

  def set_subtransactions
    @subtransactions = Transaction.where(parent_id: @transaction.id)
  end

  def start_transaction
    #add exception method
    ActiveRecord::Base.transaction do
      if @result[:transaction]
      else
        return false
      end
      @result[:transaction].save!
      @result[:subtransactions].each do |subtransaction|
        subtransaction.parent_id = @result[:transaction].id
        subtransaction.save!
      end
      @result[:wallets].each &:save!
      @result[:to_wallet].save!
    end
  end

  def transaction_params
    params.require(:transaction).permit(:to_user_id, :value, :currency_id)
  end
end
