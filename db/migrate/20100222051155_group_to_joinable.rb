class GroupToJoinable < ActiveRecord::Migration
  Group.table_name = :joinables
  def self.up
    rename_table :groups, :joinables
    add_column :joinables, :type, :string
    grps = Group.find :all
    grps.each do |g|
      g.type = "Group"
      g.save!
    end
  end

  def self.down
    remove_column :joinables, :type
    rename_table :joinables, :groups
  end
end
