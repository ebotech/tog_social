class CreateJoinablesubs < ActiveRecord::Migration
  def self.up
    create_table :joinablesubs do |t|
      t.integer :joinable_id
      t.text :aims
      t.text :timeline
      t.string :location

      t.timestamps
    end
  end

  def self.down
    drop_table :joinablesubs
  end
end
