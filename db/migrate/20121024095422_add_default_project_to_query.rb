class AddDefaultProjectToQuery < ActiveRecord::Migration
  def change
  	change_table :queries do |t|
  		t.boolean :default, :default => false, :null => false
  	end
  end
end
