class CreateMailers < ActiveRecord::Migration
  def self.up
    create_table :mailers do |t|
    end
  end

  def self.down
    drop_table :mailers
  end
end
