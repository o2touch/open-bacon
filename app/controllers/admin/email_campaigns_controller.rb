class Admin::EmailCampaignsController < Admin::AdminController

  def index       
    # Get a list of campaigns
    @campaigns = EmailCampaign.all
  end
  
  def run
    logger.debug(params.to_yaml)
    # Get Campaign
    id = params[:email_campaign_id]
    @campaign = EmailCampaign.find(id)

    # Run campaign
    EmailCampaignService.run(@campaign, params[:exclude], params[:number]) 

    redirect_to ['admin', @campaign]
  end

  def show
    id = params[:id]

    @campaign = EmailCampaign.find(id)
  end

  def preview
    id = params[:email_campaign_id]
    @campaign = EmailCampaign.find(id)
    redirect_to ['admin', @campaign] and return if @campaign.recipients.first.nil?

    if params[:template] == 'a' && !@campaign.template_a.blank?
      template = @campaign.template_a
    elsif params[:template] == 'b' && !@campaign.template_b.blank?
      template = @campaign.template_b
    else
      render text: "no such template" and return
    end

    data = @campaign.recipients.first

    email_html = render_to_string 'campaign_mailer/' + template, :layout => @campaign.layout_template, :locals => {:data => data}

    render :text => Roadie.inline_css(Roadie.current_provider, [], email_html, ActionMailer::Base.default_url_options)
  end

end