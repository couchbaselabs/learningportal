class CreateSnapshots < ActiveRecord::Migration
  def change
    create_table :snapshots do |t|
      t.integer :text_count
      t.integer :text_view_count
      t.integer :image_count
      t.integer :image_view_count
      t.integer :video_count
      t.integer :video_view_count
      t.timestamps
    end
  end
end
