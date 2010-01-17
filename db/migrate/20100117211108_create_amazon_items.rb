class CreateAmazonItems < ActiveRecord::Migration
  def self.up
    create_table :amazon_items do |t|
      t.string :asin
      t.string :title
      t.string :image_url
      t.string :amazon_url
      t.timestamps
    end
  end

  def self.down
    drop_table :amazon_items
  end
end
