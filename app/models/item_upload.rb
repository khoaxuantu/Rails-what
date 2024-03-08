class ItemUpload < ApplicationRecord
  belongs_to :user

  has_one :item_submit
end
