class Admin::ClaimProfileCampaignController < Admin::AdminController

  def index   
    @teams = UnclaimedTeamProfile.where("team_id IS NULL")

    Mailgun::init("key-01ko0xiihxjz3bpbvj451g902z49ln02","https://api.mailgun.net/v2/mail.mitoo.co/")
    
    # Get a list of campaigns
    @campaigns = Campaign.all['items']
  end
  
  def create
    
    # Take emails
    profiles = params[:profiles]
    
    # Need to create Campaign
    #Campaign.create({campaign_id: "CP0003", campaign_type: "claim_profile", from: "Andrew Crump <andrew@bluefields.com>", subject_a: "%name%, claim your team profile", template_a: "CP0003", layout_template: "layouts/campaign_claim_profile"})

    receivers = []

    profiles.each do |p|
      oProfile = UnclaimedTeamProfile.find(p)
      
      next if oProfile.contact_email.blank?

      receivers << {
        email: oProfile.contact_email,
        contact_name: oProfile.contact_name
      }
    end

    # TODO create strategy for recipients
    @campaign = EmailCampaign.find_by_campaign_id("CP0003")
    EmailCampaignService.run("CP0003") unless @campaign.nil?

    # TODO Log against Claim profile campaign model OR move to EmailCampaignSent model
    # email_log = ClaimProfileCampaignEmail.create({:profile_id => oProfile.id, :email_id => email_id, :campaign_id => campaign_id, :email_type => "initial"})

    redirect_to :action => "index"    
  end
    
end