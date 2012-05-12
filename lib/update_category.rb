module RedmineRequests
  module Hooks
    class UpdateAssignOnCategory < Redmine::Hook::ViewListener
      def controller_issues_edit_before_save(contex={})
        if context[:params] && context[:params][:category_id]
          cat = IssueCategory.find(context[:params][:category_id])
          context[:issue].assigned_to = cat.assigned_to if cat.assigned_to
        end
      end
    end
  end
end