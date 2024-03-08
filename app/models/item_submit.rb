class ItemSubmit < ApplicationRecord
  belongs_to :user
  belongs_to :item_upload
end
