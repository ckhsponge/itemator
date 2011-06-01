class SuccessAt < ActiveRecord::Migration
  def self.up
    add_column :docs, :success_at, :datetime
    Doc.update_all "success_at = updated_at"
  end

  def self.down
    remove_column :docs, :success_at
  end
end
