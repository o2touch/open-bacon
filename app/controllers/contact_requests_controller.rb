class ContactRequestsController < ApplicationController
  # POST /contact_requests
  # POST /contact_requests.json
  def create
    @contact_request = ContactRequest.create(
      :data => {}.to_s, 
      :name => params[:name], 
      :demo => params[:demo].blank? ? nil : (params[:demo] == true || params[:demo] == "true"),
      :email => params[:email], 
      :message => params[:message] || "I want a page for #{params[:club]}, I am the #{params[:position]}. Posted from Tim's unclaimed team form.", 
      :mobile => params[:mobile]
    )
    
    # don't email if it's tim's form to keep active campaign happy!
    BluefieldsMailer.delay.contact_form(@contact_request) if params[:club].nil?

    render :json => true
  end
end
