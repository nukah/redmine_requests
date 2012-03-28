class IssueNotificationFlag < ActiveRecord::Migration
  def self.up
    add_column :issue_statuses, :no_notification, :boolean, :default => false
  end

  def self.down
    remove_column :issues_statuses, :no_notification
  end
end
