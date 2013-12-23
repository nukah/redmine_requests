namespace :redmine do
  desc "Send overdue tasks"
  task :send_overdue => :environment do
    status_id ||= status ||= 13
    day_amount ||= days ||= 7
    issues = Issue.where(created_on: (Time.now-14.days)..Time.now).select { |i| ((i.journals.map { |j| j.details.any? { |jd| jd.old_value == "#{status_id}" && jd.prop_key == "status_id" } and j.created_on or nil }.compact.first || Time.zone.now) - (i.journals.map { |j| j.details.any? { |jd| jd.value == "#{status_id}" && jd.prop_key == "status_id" } and j.created_on or nil}.compact.first || Time.zone.now)).to_i/86400 > day_amount}

    Mailer.with_synched_deliveries do
      Mailer.overdue_issues('bgushin@primepress.ru', issues, status_id, day_amount).deliver
    end
  end
end
