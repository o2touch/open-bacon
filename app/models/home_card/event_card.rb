class EventCard < HomeCard

	def initialize(event)
		self.obj = event
		self.obj_type = :event
	end

	def to_json

		raise Exception.new if obj.nil?

		as_json = super

		as_json[:obj] = {
			id: obj.id,
			title: obj.title,
			time: obj.time,
			time_local: obj.time_local,
			status: obj.status,
			team: { id: obj.team.id },
		}
		as_json[:obj][:location] = obj.location unless obj.location.nil?

		if type == :event_result && !obj.result.nil?
			as_json[:obj][:result] = "#{obj.result.score_for} - #{obj.result.score_against}"
		end

		as_json
	end
end