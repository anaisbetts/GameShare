class CreateGamertagTable < ActiveRecord::Migration
  def self.up
    create_table :gamertags do |t|
      t.integer :user_id
      t.string :gamertag_yaml
      t.timestamps
    end
  end

  def self.down
    drop_table :gamertags
  end
end
