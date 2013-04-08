Rails.application.paths["app/overrides"] ||= []
Rails.application.paths["app/overrides"] << File.expand_path("../app/overrides", __FILE__)

RedmineApp::Application.config.after_initialize do
	require 'request_hooks'
	IssuesController.send(:include, ExtendedIssuesController) unless IssuesController.include?(ExtendedIssuesController)
	IssueStatusesController.send(:include, ExtendedIssueStatusesController) unless IssueStatusesController.include?(ExtendedIssueStatusesController)
	JournalObserver.send(:include, ExtendedJournalObserver) unless JournalObserver.include?(ExtendedJournalObserver)
	IssueStatus.send(:include, ExtendedIssueStatus) unless IssueStatus.include?(ExtendedIssueStatus)
	Project.send(:include, ExtendedProject) unless Project.include?(ExtendedProject)
	Issue.send(:include, ExtendedIssue) unless Issue.include?(ExtendedIssue)
	ProjectsController.send(:include, ExtendedProjectsController) unless ProjectsController.include?(ExtendedProjectsController)
	QueriesController.send(:include, ExtendedQueriesController) unless QueriesController.include?(ExtendedQueriesController)
	QueriesHelper.send(:include, ExtendedQueriesHelper) unless QueriesHelper.include?(ExtendedQueriesHelper)
	ProjectsHelper.send(:include, ExtendedProjectsHelper) unless ProjectsHelper.include?(ExtendedProjectsHelper)
end	
# ActionDispatch::Callbacks.to_prepare do
	
# end
version = `git describe --always`
Redmine::Plugin.register :redmine_requests do
  name 'Pot Requests plugin'
  author 'Mighty'
  description 'POT Requests plugin for Redmine'
  version version
  url ''
  author_url 'http://primepress.ru'
  requires_redmine :version_or_higher => '2.1.0'
end
