class RenameGroupIdToJoinableIdOnMemberships < ActiveRecord::Migration
  def self.up
    rename_column :memberships, :group_id, :joinable_id
  end

  def self.down
    rename_column :memberships, :joinable_id, :group_id
  end
end
