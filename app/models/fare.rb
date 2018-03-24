class Fare < ApplicationRecord
  enum fare_type: [:free, :donation, :payment]

  def is_free?
    !fare_type || fare_type == 'free'
  end
end
