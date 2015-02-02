class Notifier
  def initialize(settings)
    @settings = settings
    @twitter = nil
    @twilio = nil
  end
  def notify(text,services)
    success = true
    errors = []
    services.each do |service|
        case service
          when :twitter then
            send_tweet(text)
          when :twilio then
            send_sms(text)
          when :desktop then
            send_desktop(text)
          else
             errors << "#{service} not implemented"
        end
        return success if errors.empty?
    end
  end
  def send_tweet(text)
    if @twitter == nil
        require "twitter"
        @twitter = Twitter::REST::Client.new do |config|
            config.consumer_key        = @settings['twitter_consumer_key']
            config.consumer_secret     = @settings['twitter_consumer_secret']
            config.access_token        = @settings['twitter_access_token']
            config.access_token_secret = @settings['twitter_token_secret']
        end
    end
    message = @settings['twitter_handle']+" "+text
    @twitter.update message[0..139]
  end
  def send_sms(text)
    if @twilio == nil
        require 'twilio-ruby'
        @twilio = Twilio::REST::Client.new @settings['twilio_account_sid'], @settings['twilio_auth_token']
    end
    @twilio.messages.create(
      from: @settings['twilio_from_number'],
      to: @settings['twilio_to_number'],
      body: text[0..159]
    )
  end
  def send_desktop(text)
    exec "notify-send task '#{text}'"
  end
end