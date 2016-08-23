# Mailer used when emailing the BF team
class BluefieldsMailer < ActionMailer::Base

  default from: "site@mitoo.co"
  layout 'notifier'

  def contact_form(contact_request)
    @demo = contact_request.demo
    @email = contact_request.email
    @message = contact_request.message 
    @name = contact_request.name
    @mobile = contact_request.mobile

    subject = "Contact Form Submission"
    to = "andrew.crump@mitoo.co"

    mail(:to => to, :subject => subject)
  end

end