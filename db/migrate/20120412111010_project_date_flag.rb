class ProjectDateFlag < ActiveRecord::Migration
  def self.up
    add_column :projects, :dates_shown, :boolean, :default => true
  end
  
  def self.down
    remove_column :projects, :dates_shown
  end
end