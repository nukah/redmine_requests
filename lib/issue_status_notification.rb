module POTRedmine
  class Hooks < Redmine::Hook::ViewListener
    render_on :view_issue_statuses_form,
              :partial => 'issues/notification'
  end
end