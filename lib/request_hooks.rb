  ## Ассигнование заявки к группе
module RedmineHooks
  class Hooks < Redmine::Hook::ViewListener
    render_on :view_issue_statuses_form, :partial => 'issues/notification'
    render_on :view_issues_index_bottom, :partial => 'issues/js_calls'
  end

  def controller_issues_edit_before_save(context={})
    if context[:params] && context[:issue][:category_id]
      cat = IssueCategory.find(context[:issue][:category_id])
      context[:issue].assigned_to_id = cat.assigned_to_id if cat.assigned_to_id
    end
  end
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
    base.send(:include, IsProjectForGroupable)
    base.class_eval do
      helper :extended_issues
      before_filter :project_groupable, :only => [:new]
    end
  end

  # Присутствует ли параметр у проекта, который позволяет ставить в "назначенное" задачам не доступных людей,
  # а только пользователей у которых есть нужный флаг, соответствующий тому что они начальники в группе
  # Если параметр присутствует:
  # Вычисляется группа автора и другие члены этой группы
  # Вычисляются текущие "начальники групп" и проводится определение начальника из группы пользователя
  module IsProjectForGroupable
    def project_groupable
      field = ProjectCustomField.find(:first, conditions: {name: 'groupable'})
      @project_acceptable_for_groups = @project.custom_value_for(field) if field
      if @project_acceptable_for_groups
        author_group = User.find_by_sql([ "SELECT users.id FROM users LEFT JOIN groups_users ON users.id = groups_users.user_id WHERE groups_users.group_id IN (SELECT groups_users.group_id AS gid FROM groups_users WHERE groups_users.user_id = ?)", @issue.author.id ]).collect(&:id)
        @assignees = User.where(['id in (?)', UserCustomField.find(:first, conditions: ['name like ?', 'head']).custom_values.select { |cv| cv.value == "1" && author_group.include?(cv.customized_id) }.collect(&:customized_id) ])
      end
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
        if params[:id].nil?
          Query.update_all({:default => false}, ['project_id = ?', @project.id])
        else
          Query.update(params[:id], :default => true)
          Query.update_all({:default => false}, ['id <> ? AND project_id = ?', params[:id], @project.id])
        end
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
          @query = Query.find(params[:query_id])
          raise ::Unauthorized unless @query.visible?
          sort_clear
        elsif params[:set_filter]
          @query = Query.new(:name => '_')
          @query.project = @project
          build_query_from_params
        else
          @query = Query.includes(:project).where(:default => true, :project_id => @project.id).first
          (@query ||= Query.new(:name => "_") and @query.project = @project) if @query.nil?
          sort_clear
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

