class CreateDocs < ActiveRecord::Migration
  def self.up
    create_table :docs do |t|
      t.string :path, :null => false, :default => ""
      t.string :folder, :null => false, :default => ""
      t.string :title, :null => false, :default => ""
      t.string :key, :null => false, :default => ""
      t.string :status, :null => false, :default => ""
      t.boolean :parsed

      t.timestamps
    end
    add_index :docs, :path, :unique => true
    
  end

  def self.down
    drop_table :docs
  end
end
