class CreateItems < ActiveRecord::Migration[7.0]
  def change
    create_table :items do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.integer :width
      t.integer :height
      t.text :note
      t.boolean :is_ai_generated
      t.string :thumbnail_path
      t.integer :content_type, index: true

      t.timestamps
    end

    add_reference :item_uploads, :item, foreign_key: true, null: false
  end
end
