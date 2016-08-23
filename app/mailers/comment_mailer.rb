class CommentMailer < ActionMailer::Base  
  include MailerHelper
  include EmailSubjectHelper
  include IncomingMailHelper

  helper :km, :application, :mailer

  default from: NOTIFICATIONS_FROM_ADDRESS
  
  layout 'notifier'

  #########
  # These are all fucking similar now, though I've kept them separate
  #  as it make sense the the emails should be much more different than
  #  they currently are. TS
  ####


  def message_comment_created(recipient_id, tenant_id, data)
  	@tenant = Tenant.find(tenant_id)
  	@recipient = User.find(recipient_id)

  	@comment = ActivityItemComment.find(data[:comment_id])
  	@actor = User.find(data[:actor_id])
  	@activity_item = ActivityItem.find(data[:activity_item_id])
  	@original_comment = @activity_item.obj.text

  	@feed_owner = data[:feed_owner_type].constantize.find(data[:feed_owner_id])

    from = determine_mail_from_for_user_email(@comment.user)
    subject = subject_for_comment_posted(@comment)
    to = format_email_to_user(@recipient)
    
    headers['Reply-To'] = encode_reply_to(@recipient, @activity_item)
    headers['References'] = encode_message_id(@recipient, @activity_item.obj)
    oof_header
    mail(:from => from, :to => to, :subject => subject)  	
  end

  def invite_response_comment_created(recipient_id, tenant_id, data)
   	@tenant = Tenant.find(tenant_id)
  	@recipient = User.find(recipient_id)

  	@comment = ActivityItemComment.find(data[:comment_id])
  	@actor = User.find(data[:actor_id])
  	@activity_item = ActivityItem.find(data[:activity_item_id])

  	@feed_owner = data[:feed_owner_type].constantize.find(data[:feed_owner_id])

  	ir = @activity_item.obj
    _not_ = ir.response_status == 0 ? " not " : " "
    @original_comment = "#{ir.teamsheet_entry.user.name} is#{_not_}playing the event"

    from = determine_mail_from_for_user_email(@comment.user)
    subject = subject_for_comment_posted(@comment)
    to = format_email_to_user(@recipient)
    
    headers['Reply-To'] = encode_reply_to(@recipient, @activity_item)
    oof_header
    mail(:from => from, :to => to, :subject => subject)  	
  end
end