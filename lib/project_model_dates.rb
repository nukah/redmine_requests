require_dependency 'project'

module ProjectModelPatch
  def self.included(base)
    base.class_eval do
      safe_attributes('dates_shown')
      def date_activated?
        self.dates_shown
      end
    end
  end
end