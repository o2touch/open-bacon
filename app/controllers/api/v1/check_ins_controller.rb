class Api::V1::CheckInsController < Api::V1::ApplicationController
	def create
		tse = TeamsheetEntry.find(params[:id])

		authorize! :check_in, tse

		TeamsheetEntriesService.check_in(tse)

		render status: :ok, json: {}
	end

	# expect { 1123 => 0, 1124 => 1, ... }
	def bulk
		raise InvalidParameter.new("Checkins not provided") unless params.has_key? :check_ins
		raise InvalidParameter.new("Checkins not provided") if params[:check_ins].empty?

		# all or nothing...
		ActiveRecord::Base.transaction do
			params[:check_ins].each do |k, v|
				tse = TeamsheetEntry.find(k)
				authorize! :check_in, tse

				TeamsheetEntriesService.check_in(tse) if v == '1'
				TeamsheetEntriesService.check_out(tse) if v == '0' 
				raise InvalidParameter.new("Invalid check in value '#{v}' for id: #{k}") if v != '1' && v != '0'
			end
		end

		render status: :ok, json: {}
	end

	def destroy
		tse = TeamsheetEntry.find(params[:id])

		authorize! :check_in, tse

		TeamsheetEntriesService.check_out(tse)

		render status: :ok, json: {}
	end
end