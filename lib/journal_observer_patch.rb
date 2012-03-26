require_dependency 'journal_observer'

class JournalObserver
  def after_create(journal)
    send = false
    if journal.notify? &&
        (Setting.notified_events.include?('issue_updated') ||
          (Setting.notified_events.include?('issue_note_added') && journal.notes.present?) ||
          (Setting.notified_events.include?('issue_status_updated') && journal.new_status.present?) ||
          (Setting.notified_events.include?('issue_priority_updated') && journal.new_value_for('priority_id').present?)
        )
        send = true
    end
    
    if journal.new_status.present? && journal.new_value_for('status_id') in [13]
      send = false
    end
    
    Mailer.deliver_issue_edit(journal) if send
  end
end