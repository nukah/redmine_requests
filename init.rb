require_dependency 'hooks'

ActionDispatch::Callbacks.to_prepare do
	IssuesController.send(:include, ExtendedIssuesController)
	IssueStatusesController.send(:include, ExtendedIssueStatusesController)
	JournalObserver.send(:include, ExtendedJournalObserver)
	IssueStatus.send(:include, ExtendedIssueStatus)
	Project.send(:include, ExtendedProject)
	Issue.send(:include, ExtendedIssue)
	ProjectsController.send(:include, ExtendedProjectsController)
	QueriesController.send(:include, ExtendedQueriesController)
	QueriesHelper.send(:include, ExtendedQueriesHelper)
	ProjectsHelper.send(:include, ExtendedProjectsHelper)
end

Redmine::Plugin.register :pot_requests do
  name 'Pot Requests plugin'
  author 'Mighty'
  description 'POT Requests plugin for Redmine'
  version '1.0'
  url ''
  author_url 'http://primepress.ru'
end
