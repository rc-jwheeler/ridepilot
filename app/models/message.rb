class Message < ApplicationRecord
  belongs_to :provider
  belongs_to :sender, class_name: 'User', foreign_key: :sender_id
  belongs_to :reader, class_name: 'User', foreign_key: :reader_id
end
