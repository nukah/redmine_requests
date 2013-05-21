Deface::Override.new :virtual_path  => 'issues/_list',
                     :name          => 'add-refresh-for-issues-index',
                     :original      => "9c148c5bcbf241e7bd2fb41cce68b18583f55a43",
                     :insert_before    => "div.autoscroll",
                     :text    => "<% content_for :header_tags do %><%= javascript_include_tag('refresh_issues', :plugin => 'redmine_requests') %><% end %>"