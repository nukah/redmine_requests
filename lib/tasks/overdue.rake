namespace :redmine do
  desc "Send overdue tasks"
  task :send_overdue => :environment do
    status ||= 13
    days ||= 7
    project ||= 1

    filter = lambda { |i| ((i.journals.map { |j| j.details.any? { |jd| jd.old_value == "#{status}" && jd.prop_key == "status_id" } and j.created_on or nil }.compact.first || Time.zone.now) - (i.journals.map { |j| j.details.any? { |jd| jd.value == "#{status}" && jd.prop_key == "status_id" } and j.created_on or nil}.compact.first || Time.zone.now)).to_i }
    issues = Issue.includes(:status).where("#{IssueStatus.table_name}.is_closed = ? AND #{Issue.table_name}.project_id = ?", false, project).select { |issue| filter.call(issue)/86400 > days }
    overdue = Hash[*issues.map { |i| [i.id, filter.call(i)/86400] }.flatten]
    Mailer.with_synched_deliveries do
      Mailer.overdue_issues('bgushin@primepress.ru', issues, status, days, overdue).deliver
    end
  end
end
