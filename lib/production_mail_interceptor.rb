class ProductionMailInterceptor
  # def self.delivering_email(message)
  #   unless deliver?(message)
  #     message.perform_deliveries = false
  #     Rails.logger.warn "Interceptor prevented sending mail #{message.inspect}!"
  #   end
  # end

  def self.delivering_email(message)
    
    old_from = message.header['From'].to_s
    old_to = message.header['To'].to_s

    message.from = "<hurst@mitoo.co>"
    message.subject = "FROM: #{old_from} TO: #{old_to} SUBJECT: #{message.subject}"
    message.to = "staging@mitoo.co"
  end

  def self.deliver?(message)
    begin
      email = Mail::Address.new(message.to).address
      return User.where( :email => email ).first.should_send_email? 
    rescue
      true #Let action mailer handle this.
    end
  end
end
