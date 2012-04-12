Project.class_eval do
  safe_attributes('dates_shown')
  def date_activated?
    self.dates_shown
  end
end