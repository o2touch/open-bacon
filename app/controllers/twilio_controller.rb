class TwilioController < ApplicationController
  
  # before_filter :check_permissions
  
  def voice
    from = params[:From]

    @user = nil
    @user = User.find_by_mobile_number(from) unless from.nil?

    @name = ""
    @name = @user.name.split(' ')[0] unless @user.nil?

    # this seems to be erroring. TS
    render :action => 'voice.xml.builder', :layout => false
  end

  # GET /twilio
  def sms_reply
    from = params[:From]
    sms_body = params[:Body].strip.upcase

    user = User.find_by_mobile_number(from)

    # figure out if it was a valid response
    response = nil # invalid!
    response = 1 if sms_body[0] == 'Y'
    response = 0 if sms_body[0] == 'N'

    # save what they sent, just in case.
    reply = SmsReply.create(:content => params[:Body], :number => from)

    # create an SmsReply if it was, update tse shit
    # fucked
    if user.nil?
      output = "Sorry, we couldn't process your response"

    # fucked
    elsif response.nil?
      output = "Unfortuantely that was an invalid response! Please try again."

    # not fucked
    else
      response_code = 0 if sms_body.length == 1
      response_code = sms_body[1].to_i if sms_body.length > 1

      # load the shit
      sms_sent = SmsSent.where(sms_reply_code: response_code, user_id: user.id).last
      tse = sms_sent.teamsheet_entry
      tenant = LandLord.new(tse.event.team).tenant

      # make the changes
      ir = TeamsheetEntriesService.set_availability(tse, response, user)
      tse.send_push_notification("update")

      # bloody i18n
      response_text = I18n.t "general.availability.available", locale: tenant.i18n if response == 1
      response_text = I18n.t "general.availability.unavailable", locale: tenant.i18n if response == 0

      player = "you" if tse.user == user
      player = tse.user.name.titleize unless tse.user == user

      output = "Thanks #{user.name}. We've put #{player} down as #{response_text}."
    end

    # send some shit back.
    render xml: { Sms: output }.to_xml(:root => 'Response')

  rescue => e
    output = "Sorry, something went wrong and we were unable to process your message."
    render xml: { Sms: output }.to_xml(:root => 'Response')
  end

  # def sms_reply
  #   # TODO: This is all horribel and needs a big refactor. TS
  #   begin
  #     #Extract ID from response
  #     from = params[:From]
  #     #from = from.strip.sub("+","")
      
  #     response = params[:Body].strip
  #     response.upcase!
      
  #     value = nil
  #     if response[0]=="Y"
  #       value = "Y"
  #     elsif response[0]=="N"
  #       value = "N"
  #     end
      
  #     if value == nil
  #       render :nothing => true
  #       return
  #     end
      
  #     if response.length == 1
  #       replyCode = 0
  #     else
      
  #       begin
  #         replyCode = Integer(response[1])
  #       rescue ArgumentError
         
  #       end
  #     end
    
  #     logger.info "FROM " + from  
  #     logger.info "RESPONSE IS " + value
  #     logger.info "CODE " + replyCode.to_s
      
  #     @sms_sent = SmsSent.find(:all, :conditions => { :sms_reply_code => replyCode, :to => from }, :order => "created_at DESC")
      
  #     logger.info "SMS SENT: " + @sms_sent.size.to_s
  #     if @sms_sent.size != 0
  #       reply = SmsReply.create(:content => params[:Body], :number => from)
      
  #       @sms_sent[0].sms_reply_id = reply.id
  #       @teamsheet_entry = TeamsheetEntry.find(@sms_sent[0].teamsheet_entry_id)
        
  #       if value == "N"
  #         response_status = 0
  #         valueText = "unavailable"
  #       else
  #         response_status = 1
  #         valueText = "available"
  #       end
        
  #       # identity using mobile number for now
  #       @user = User.find(@sms_sent[0].user_id)
  #       @name = @user.name
              
        # @invite_response = TeamsheetEntriesService.set_availability(@teamsheet_entry, response_status, @user)

  #       if !@invite_response.nil?
  #         @output = {:Sms => "Thanks #{@name}. We've put you down as #{valueText}"}

  #         #TODO: Move this into InviteResponse Observer

  #         @teamsheet_entry.send_push_notification("update")
  #       else
  #         @output = {:Sms => "Sorry #{@name}, something went wrong and we haven't been able to save your response."}
  #       end
  #     else
  #       @output = {:Sms => "Sorry #{@name}, we couldn't find a game for your response '#{response}'."}
  #     end
  #      @invite_response = TeamsheetEntriesService.set_availability(@teamsheet_entry, response_status, @user)
  #   rescue Exception => e
  #     @output = {:Sms => "Sorry, something went wrong."}
  #     Rails.logger.warn "Something went wrong: #{e.message}, #{e.backtrace}"
  #   end

  #   render :xml => @output.to_xml(:root => 'Response')
  # end
end
