module AdditionHelper
  def principals_options_for_select(collection, selected=nil)
    s = ''
    groups = ''
    collection.sort.each do |element|
      selected_attribute = ' selected="selected"' if option_value_selected?(element, selected)
      element.is_a?(Group) ? groups << %(<option value="#{element.id}"#{selected_attribute}>#{h element.name}</option>) : nil
    end
    unless groups.empty?
      s << %(<optgroup label="#{h(l(:label_group_plural))}">#{groups}</optgroup>)
    end
    s
  end
  
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