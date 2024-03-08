class CreateItemSubmits < ActiveRecord::Migration[7.0]
  def change
    create_table :item_submits do |t|
      t.references :user, null: false, foreign_key: true
      t.references :item_upload, null: false, foreign_key: true
      t.string :original_image_path

      t.timestamps
    end
  end
end
