# class Api::V1::ActiveCampaignCallbacksController < Api::V1::ApplicationController
# 	skip_authorization_check only: [:sent, :create]
# 	skip_before_filter :authenticate_user!, only: [:sent, :create]


# 	def sent
# 		# 1 - (basic) Initial Contact
# 		# 2 - (basic) Did you get my email?
# 		# 3 - (basic) Mobile app updates?
# 		# 4 - (basic) Did you get a chance to checkout bluefields yet?
# 		# 5 - (club_created) We have just created a page for your club
# 		# 6 - (club_created) Did you forward to those dickhead yet?
# 		# 7 - (dygme) I pretended that I sent you an email, but I didn't LOLOLOLOLOLOL
# 		# 8 - (please help) Initial Contact

# 		cmd = ClubMarketingData.find_by_contact_email(params[:contact][:email])

# 		if cmd.nil?
# 			club = Club.find_by_id(params[:contact][:fields]['11'][:val])
# 			cmd = club.marketing
# 		end

# 		if !cmd.nil?
# 			cmd.club_marketing_events.create({
# 				date: Time.now,
# 				event_type: "sent",
# 				email_id: params[:email_id],
# 				data: params
# 			})
# 		end

# 		head :ok
# 	end

# 	def create
# 		cmd = ClubMarketingData.find_by_contact_email(params[:contact][:email])

# 		if cmd.nil?
# 			club = Club.find_by_id(params[:contact][:fields]['11'][:val])
# 			cmd = club.marketing
# 		end

# 		if !cmd.nil?
# 			cmd.club_marketing_events.create({
# 				date: Time.now,
# 				event_type: params[:type],
# 				email_id: params[:campaign][:id],
# 				data: params
# 			})
# 		end

# 		head :ok
# 	end

# end