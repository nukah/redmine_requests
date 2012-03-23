JournalObserver.class_eval do
  def after_create(journal)
    puts 'JournalObserver flag'
    if journal.notify? &&
        (Setting.notified_events.include?('issue_updated') ||
          (Setting.notified_events.include?('issue_note_added') && journal.notes.present?) ||
          (Setting.notified_events.include?('issue_status_updated') && journal.new_status.present?) ||
          (Setting.notified_events.include?('issue_priority_updated') && journal.new_value_for('priority_id').present?)
        )
      Mailer.deliver_issue_edit(journal)
    end
  end
  
  def after_update(journal)
    puts journal
    Mailer.deliver_issue_edit(journal) unless journal.new_value_for('status_id') in [13]
  end
end