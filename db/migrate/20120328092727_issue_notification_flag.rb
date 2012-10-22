class IssueNotificationFlag < ActiveRecord::Migration
  def change
    add_column :issue_statuses, :no_notification, :boolean, :default => false
  end
end
