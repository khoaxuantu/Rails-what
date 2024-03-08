class CreateItemUploads < ActiveRecord::Migration[7.0]
  def change
    create_table :item_uploads do |t|
      t.references :user, null: false, foreign_key: true
      t.string :item_upload_path

      t.timestamps
    end
  end
end
