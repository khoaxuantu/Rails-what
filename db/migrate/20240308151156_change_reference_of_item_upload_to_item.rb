class ChangeReferenceOfItemUploadToItem < ActiveRecord::Migration[7.0]
  def change
    change_column :item_uploads, :item_id, :bigint, :null => true
  end
end
