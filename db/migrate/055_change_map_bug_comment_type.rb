class ChangeMapBugCommentType < ActiveRecord::Migration[4.2]
  def self.up
    change_column :map_bug_comment, :comment, :text
  end

  def self.down
    change_column :map_bug_comment, :comment, :string
  end
end
