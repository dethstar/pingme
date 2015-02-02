require File.expand_path(File.dirname(__FILE__) + '/notifier')
class Pinger
  def initialize(settings)
    @settings = settings
    @notifier = Notifier.new settings
    @services = []
    @settings['services'].each do |s|
      @services.push(s.to_sym)
    end
  end
  def has_any_term?(terms,text)
      terms.each do |term|
        return true if text.include? term
      end
      return false
  end

  def has_all_terms?(terms,text)
    terms.each do |term|
      return false unless text.include? term
    end
  end

  def search_terms(terms,text,search_type=:any)
      if search_type==:all
        return has_all_terms?(terms,text)
      else
        return has_any_term?(terms,text)
      end
  end

  def get_emails(service,sender)
    case service
      when :gmail then
          require 'gmail'
          gmail = Gmail.new(@settings["email"],@settings["password"])
          gmail.peek = true
          return gmail.inbox.emails(:unread, :from=>sender)
      else "Implement it :)"
    end
  end

  def start(search_type=:any)
    @settings['senders'].each do |sender|
        get_emails(:gmail,sender).each do |email|
            if search_terms(@settings['terms'],email.body.to_s.downcase,search_type)
              @notifier.notify(email.subject,@services)
              email.mark(:read)
            end
        end
    end
  end
end