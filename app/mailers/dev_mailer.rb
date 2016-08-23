class DevMailer < ActionMailer::Base
  
  default from: "dev_notifiers@mitoo.co"
  add_template_helper(ApplicationHelper)
  layout 'notifier'
    
  def api_application_submitted(api_application)
    @api_application = api_application    
    
    from = "Mitoo Dev Notifiers"
    to = "Mitoo Team <team@mitoo.co>"
    subject = "Mitoo API Application?"
    
    mail(:from => from, :to => to, :subject => subject)
  end
  
end
