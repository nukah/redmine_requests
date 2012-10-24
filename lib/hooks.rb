  ## Ассигнование заявки к группе
class UpdateAssignOnCategory < Redmine::Hook::ViewListener
def controller_issues_edit_before_save(context={})
  if context[:params] && context[:issue][:category_id]
    cat = IssueCategory.find(context[:issue][:category_id])
    context[:issue].assigned_to_id = cat.assigned_to_id if cat.assigned_to_id
  end
end
end

class ChangeIssueNotification < Redmine::Hook::ViewListener
	render_on :view_issue_statuses_form,
          :partial => 'issues/notification'
    render_on :view_issues_index_bottom,
    	  :partial => 'issues/jscalls'
end

  ## Привязка статуса к проекту
  ## Даты
module ExtendedProject
	def self.included(base)
		base.class_eval do
			safe_attributes('dates_shown')
			has_many :issue_statuses
			def date_activated?
				self.dates_shown
			end
		end
	end
end

module ExtendedIssue
	def self.included(base)
		base.class_eval do
			def new_statuses_allowed_to(user=User.current, include_default=false)
				if new_record? && @copied_from
					[IssueStatus.default_of_project(project), @copied_from.status].compact.uniq.sort
				else
					initial_status = nil
					if new_record?
						initial_status = IssueStatus.default_of_project(project)
					elsif status_id_was
						initial_status = IssueStatus.find_by_id(status_id_was)
					end
					initial_status ||= status

					statuses = initial_status.find_new_statuses_allowed_to(
								user.admin ? Role.all : user.roles_for_project(project),
								tracker,
								author == user,
								assigned_to_id_changed? ? assigned_to_id_was == user.id : assigned_to_id == user.id
							   )
					statuses << initial_status unless statuses.empty?
					statuses << IssueStatus.default_of_project(project) if include_default
					statuses = statuses.compact.uniq.sort
					blocked? ? statuses.reject {|s| s.is_closed?} : statuses
				end
			end
		end
	end
end

  ## Статус привязан к проекту
module ExtendedIssueStatus
	def self.included(base)
  		base.class_eval do
  			belongs_to :project

  			def update_default
  				IssueStatus.update_all({:is_default => false}, ['id <> ? AND project_id = ?', id, self.project_id]) if self.is_default?
  			end

  			def self.default_of_project(project)
  				includes(:project).where(:is_default => true, :project_id => project).first
  			end
  		end
  	end
end

module ExtendedIssuesController
	def self.included(base)
		base.class_eval do
			helper :extended_issues
		end
	end
end

module ExtendedJournalObserver
	def self.included(base)
		base.class_eval do
			def after_create_with_checks journal
				send = false
				if journal.notify? &&
				(Setting.notified_events.include?('issue_updated') ||
				(Setting.notified_events.include?('issue_note_added') && journal.notes.present?) ||
				(Setting.notified_events.include?('issue_status_updated') && journal.new_status.present?) ||
				(Setting.notified_events.include?('issue_priority_updated') && journal.new_value_for('priority_id').present?)
				)
					send = true
				end

				if (journal.new_status.present? && IssueStatus.find(:all, :conditions => { :no_notification => true }).map(&:id).include?(journal.new_value_for('status_id')))
					send = false
				end

				Mailer.issue_edit(journal).deliver if send
			end
			alias_method_chain :after_create, :checks
		end
	end
end

module IssuesHelper
  def render_issue_subject_with_tree(issue)
    s = ''
    ancestors = issue.root? ? [] : issue.ancestors.visible.all
    ancestors.each do |ancestor|
      s << '<div>' + content_tag('p', link_to_issue(ancestor))
    end
    s << '<div>'
    subject = h(issue.subject)
    s << content_tag('h3', subject)
    s << '</div>' * (ancestors.size + 1)
    s.html_safe
  end
end

module ExtendedIssueStatusesController
	def self.included(base)
	  base.class_eval do
  		def edit_new
  			@issue_status = IssueStatus.find(params[:id])
  			@projects = Project.active
  		end
		  alias_method :edit, :edit_new
	  end
	end
end

module ExtendedProjectsController
  def self.included(base)
    base.class_eval do
      def settings
        @issue_custom_fields = IssueCustomField.find(:all, :order => "#{CustomField.table_name}.position")
        @issue_category ||= IssueCategory.new
        @member ||= @project.members.new
        @trackers = Tracker.sorted.all
        @wiki ||= @project.wiki
        @queries ||= Query.where(:project_id => @project.id)
      end
    end
  end
end

module ExtendedQueriesController
  def self.included(base)
    base.class_eval do
      before_filter :find_project_by_project_id, :only => [:set_default]
      def set_default
        Query.update(@query.id, :default => true)
        Query.update_all({:default => false}, ['id <> ? AND project_id = ?', @query.id, @project.id])
        redirect_to project_path(@project)
      end
    end
  end
end

module ExtendedQueriesHelper
  def self.included(base)
    base.module_eval do
      def retrieve_query
        if !params[:query_id].blank?
          cond = "project_id IS NULL"
          cond << " OR project_id = #{@project.id}" if @project
          @query = Query.find(params[:query_id], :conditions => cond)
        raise ::Unauthorized unless @query.visible?
          @query.project = @project
          session[:query] = {:id => @query.id, :project_id => @query.project_id}
          sort_clear
        elsif api_request? || params[:set_filter] || session[:query].nil? || session[:query][:project_id] != (@project ? @project.id : nil)
          # Give it a name, required to be valid
          @query = (Query.includes(:project).where(:default => true, :project_id => @project).first or Query.new(:name => "_"))
          @query.project = @project
          build_query_from_params
          session[:query] = {:project_id => @query.project_id, :filters => @query.filters, :group_by => @query.group_by, :column_names => @query.column_names}
        else
          # retrieve from session
          @query = Query.find_by_id(session[:query][:id]) if session[:query][:id]
          @query ||= Query.new(:name => "_", :filters => session[:query][:filters], :group_by => session[:query][:group_by], :column_names => session[:query][:column_names])
          @query.project = @project
        end
      end
    end
  end
end

module ExtendedProjectsHelper
  def self.included(base)
    base.module_eval do
      def project_settings_updated_tabs
        tabs = [{:name => 'info', :action => :edit_project, :partial => 'projects/edit', :label => :label_information_plural},
              {:name => 'modules', :action => :select_project_modules, :partial => 'projects/settings/modules', :label => :label_module_plural},
              {:name => 'members', :action => :manage_members, :partial => 'projects/settings/members', :label => :label_member_plural},
              {:name => 'versions', :action => :manage_versions, :partial => 'projects/settings/versions', :label => :label_version_plural},
              {:name => 'categories', :action => :manage_categories, :partial => 'projects/settings/issue_categories', :label => :label_issue_category_plural},
              {:name => 'wiki', :action => :manage_wiki, :partial => 'projects/settings/wiki', :label => :label_wiki},
              {:name => 'repositories', :action => :manage_repository, :partial => 'projects/settings/repositories', :label => :label_repository_plural},
              {:name => 'boards', :action => :manage_boards, :partial => 'projects/settings/boards', :label => :label_board_plural},
              {:name => 'activities', :action => :manage_project_activities, :partial => 'projects/settings/activities', :label => :enumeration_activities},
              {:name => 'queries', :action => :edit_project, :partial => 'projects/settings/default_query', :label => :label_queries_plural}
              ]
        tabs.select {|tab| User.current.allowed_to?(tab[:action], @project)}
      end
      alias_method :project_settings_tabs, :project_settings_updated_tabs
    end
  end
end

