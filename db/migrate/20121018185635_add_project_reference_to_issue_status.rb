class AddProjectReferenceToIssueStatus < ActiveRecord::Migration
  def change
  	change_table :issue_statuses do |t|
  		t.references :project
  	end
  end
end
