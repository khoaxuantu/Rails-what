class Item < ApplicationRecord
  belongs_to :user

  has_one :item_submit
  has_one :item_upload
end
