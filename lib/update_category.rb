module RedmineRequests
  module Hooks
    class UpdateAssignOnCategory < Redmine::Hook::ViewListener
      def controller_issues_edit_before_save(context={})
        if context[:params] && context[:issue][:category_id]
          cat = IssueCategory.find(context[:issue][:category_id])
          context[:issue].assigned_to_id = cat.assigned_to_id if cat.assigned_to_id
        end
      end
    end
  end
end