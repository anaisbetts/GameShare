class AddNameToGamertag < ActiveRecord::Migration
  def self.up
    add_column :gamertags, :name, :string
  end

  def self.down
    remove_column :gamertags, :name
  end
end
