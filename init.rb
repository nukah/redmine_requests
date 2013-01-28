require_dependency 'hooks'

ActionDispatch::Callbacks.to_prepare do
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
version = `git describe --always`
Redmine::Plugin.register :redmine_requests do
  name 'Pot Requests plugin'
  author 'Mighty'
  description 'POT Requests plugin for Redmine'
  version version
  url ''
  author_url 'http://primepress.ru'
end
