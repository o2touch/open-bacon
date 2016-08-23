class StagingMailInterceptor
  def self.delivering_email(message)
    
    old_from = message.header['From'].to_s
    old_to = message.header['To'].to_s

    message.from = "<hurst@mitoo.co>"
    message.subject = "FROM: #{old_from} TO: #{old_to} SUBJECT: #{message.subject}"
    message.to = "o2touch-staging@mitoo.co"
  end
end