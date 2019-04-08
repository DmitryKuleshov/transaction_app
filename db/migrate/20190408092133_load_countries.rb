class LoadCountries < ActiveRecord::Migration[4.2]
  def up
    require File.expand_path('../../seed/country_seeds.rb', __FILE__)
  end

  def down
    Country.delete_all
  end
end
