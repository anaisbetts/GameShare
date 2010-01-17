class CreateAcls < ActiveRecord::Migration
  def self.up
    create_table :acls do |t|
      t.integer :user_id
      t.integer :group_id
      t.integer :type

      t.timestamps
    end
  end

  def self.down
    drop_table :acls
  end
end
