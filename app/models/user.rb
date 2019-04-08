class User < ApplicationRecord
  belongs_to :country

  devise :database_authenticatable, :registerable,
         :rememberable, :validatable

end
