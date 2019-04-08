Country.all.each do |country|
  country = ISO3166::Country.new(country.iso)
  if country
    currency_code = country.currency_code
    Currency.create(abbreviation: currency_code)
  end
end
