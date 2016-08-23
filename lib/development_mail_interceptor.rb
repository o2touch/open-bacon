require 'socket'

class DevelopmentMailInterceptor
  def self.delivering_email(message)

    host = Socket.gethostname
    old_from = message.header['From'].to_s
    old_to = message.header['To'].to_s

    message.from = host + "<hurst@mitoo.co>"
    message.subject = "FROM: #{old_from} TO: #{old_to} SUBJECT: #{message.subject}"
    message.to = "set@me.org.uk"
  end
end