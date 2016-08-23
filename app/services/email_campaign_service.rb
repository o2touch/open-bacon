class EmailCampaignService

  class << self
    def run(campaign, emails_to_exclude, total_to_send)
            
      emails_to_send = []
      emails_to_exclude ||= []
      # if they don't give us a number send 50
      total_to_send = total_to_send.to_i rescue total_to_send = 50

      Rails.logger.debug("sending total_to_send: #{total_to_send}")
      
      # Reject non emails
      new_recipients = campaign.new_recipients.reject{ |p| !p[:email].match(/\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/) }

      puts new_recipients.size

      new_recipients = new_recipients.reject{ |p| emails_to_exclude.include?(p[:email]) }

      total_to_send = new_recipients.size if new_recipients.size < total_to_send

      # Choose random sample from recipients
      new_recipients = new_recipients.sample(total_to_send)

      # For each receivers generate email
      new_recipients.each_with_index do |p, i|
      
        # Skip if email address is blank
        next if p[:email].blank?
        
        fullname = p[:contact_name].titleize.split(' ') unless p[:contact_name].nil?
        mailgun_campaign_id = campaign.campaign_id + "_"

        template_id = campaign.template_a
        subject = campaign.subject_a
        
        # Check email template exists
        filename = "campaign_mailer/"+template_id
        File.exist?(filename)

        # Render email template
        av = ActionView::Base.new(BluefieldsRails::Application.config.paths["app/views"].first)
        email_text = ""
        email_html = av.render( :file => filename, :layout => campaign.layout_template, :locals => { :data => p } ).to_str
        
        email_inline_html = av.render(:text => Roadie.inline_css(Roadie.current_provider, [], email_html, ActionMailer::Base.default_url_options))

        Rails.logger.info "Queuing email for " + p[:email]
              
        # Queue for sending
        emails_to_send << {
          :from => campaign.from,
          :to => p[:email],
          :subject => subject,
          :email_text => email_text,
          :email_html => email_inline_html,
          :email_campaign_id => campaign.id,
          :campaign_id => campaign_id,
          :template_id => template_id,
          :mailgun_campaign_id => mailgun_campaign_id,
          :data => p
        }
      end

      emails_sent = self.send_emails(emails_to_send)
    end


    def send_emails(emails)
      if !Rails.env.production? && false
        emails.each do |e|
          Rails.logger.info "EMAIL CAMPAIGN: "
        end
      else
        return self.send_emails_with_mailgun(emails)
      end
    end


    def send_emails_with_mailgun(emails)
      test_mode = Rails.env.production? ? false : true

      # Connect to Mailgun
      Mailgun::init("key-01ko0xiihxjz3bpbvj451g902z49ln02","https://api.mailgun.net/v2/mail.mitoo.co/")

      emails_sent = []

      emails.each do |e|

        next if emails_sent.include?(e[:to])

        Rails.logger.info "Sending email: " + e[:to] + " " + e[:subject] + " " + e[:mailgun_campaign_id]

        # Send using MailGun
        Campaign.send(e[:from], e[:to], e[:subject], e[:email_text], e[:email_html], e[:mailgun_campaign_id], test_mode)

        # Log sent
        email_log = EmailCampaignSent.create({
          :email_campaign_id => e[:email_campaign_id],
          :email => e[:to],
          :template_id => e[:template_id],
          :data => e[:data],
        })

        emails_sent << e[:to]
      end

      emails_sent
    end


    def get_campaign_stats(campaign_id)

    end
  end
end