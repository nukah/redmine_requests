require 'redmine'

config.to_prepare do 
  require_dependency 'journal_observer_patch'
  require_dependency 'mailer_patch'
  require_dependency 'issue_status_notification'
  require_dependency 'project_model_dates'
end

require 'update_category'

Redmine::Plugin.register :redmine_requests do
  name 'Redmine POT updates'
  author 'Mighty'
  description 'Infrastructure updates'
  version '0.0.7'
  url 'http://github.com/nukah/redmine_pot'
  author_url 'http://primepress.ru'
end
