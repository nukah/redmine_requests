Mailer.class_eval do 
  def create_mail
    # Removes the current user from the recipients and cc
    # if he doesn't want to receive notifications about what he does
    @author ||= User.current
    if @author.pref[:no_self_notified]
      recipients.delete(@author.mail) if recipients
      cc.delete(@author.mail) if cc
    end

    notified_users = [recipients, cc].flatten.compact.uniq
    # Rails would log recipients only, not cc and bcc
    mylogger.info "Sending email notification to: #{notified_users.join(', ')}" if mylogger

    # Blind carbon copy recipients
    if Setting.bcc_recipients?
      bcc(notified_users)
      recipients []
      cc []
    end
    s = Base64.encode64(@subject)
    @subject = ''
    s.split.each { |part| @subject << "=?utf-8?B?#{part.strip}?=\r\n" }
    super
  end
end