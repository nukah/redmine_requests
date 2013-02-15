Deface::Override.new :virtual_path  => 'projects/show',
                     :original      => 'projects_page_deface',
                     :name          => 'replace-view-issues-link',
                     :replace    => "code[erb-loud]:contains('l(:label_issue_view_all)')",
                     :text		=> "<%= link_to l(:label_issue_view_all), :controller => 'issues', :action => 'index', :project_id => @project %>"