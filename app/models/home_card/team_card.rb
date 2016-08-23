class TeamCard < HomeCard

	attr_accessor :stats

	def initialize(team)
		self.obj = team
		self.obj_type = :team
		self.stats = {}
	end

	def to_json

		raise Exception.new if obj.nil?

		as_json = super

		as_json[:obj] = {
			:id => obj.id
		}

		as_json[:data] = {
			:position => stats[:position],
			:form => stats[:form],
			:played => stats[:played],
			:won => stats[:won],
		}

		return as_json
	end
end