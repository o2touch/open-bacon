class EmailCampaign < ActiveRecord::Base
  attr_accessible :campaign_id, :subject_a, :template_a, :subject_b, :template_b, :from
  after_initialize :init

  has_many :email_campaign_sents

  # Set up Recipients strategy for this campaign, default to TestRecipient strategy  
  def init
    class_type = self.recipient_strategy_class_type.nil? ? "TestRecipients" : self.recipient_strategy_class_type
    self.recipients_strategy = Object.const_get(class_type)
  end

  def recipients_strategy=(strategy_class)
    @recipients_strategy = strategy_class
  end

  def recipients
    @recipients_strategy.get_recipients
  end

  # they haven't received an email yet
  def new_recipients
    used_emails = self.email_campaign_sents.map{ |ecs| ecs.email }
    @recipients_strategy.get_recipients.select{ |r| !used_emails.include? r[:email] }
  end

=begin
  def follow_up_recipients
    if @recipients_strategy.respond_to? :get_follow_up_recipients
      return @recipients_strategy.get_follow_up_recipients
    else
      return []
    end
  end
=end

  def ab_test?
    !subject_b.blank? && !template_b.blank?
  end
end
