class LoadCurrencies < ActiveRecord::Migration[4.2]
  def up
    require File.expand_path('../../seed/currency_seeds.rb', __FILE__)
  end

  def down
    Currency.delete_all
  end
end
