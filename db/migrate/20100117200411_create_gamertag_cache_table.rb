class CreateGamertagCacheTable < ActiveRecord::Migration
  def self.up
    create_table :gamertag_cache do |t|
      t.integer :user_id
      t.string :gamertag_yaml
      t.timestamps
    end
  end

  def self.down
    drop_table :gamertag_cache
  end
end
