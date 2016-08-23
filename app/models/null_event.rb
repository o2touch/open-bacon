class NullEvent
	attr_accessor :id, :title

	attr_accessor :location, :time, :title, :created_at, :game_type, :game_type_string, :team_id, :team

	DEFAULT_TITLE = "Unknown Event"
	DEFAULT = "unknown"
	DEFAULT_ID = -1
	
	def initialize(params=nil)
		if params.is_a?(Hash)
			self.title = params[:title] || params["title"] || DEFAULT_TITLE
			self.location = params[:location] || params["location"] || DEFAULT
			self.time = params[:time] || params["time"] || nil
			self.created_at = params[:created_at] || params["created_at"] || nil
			self.game_type = params[:game_type] || params["game_type"] || DEFAULT
			self.team_id = params[:team_id] || params["team_id"] || nil

			self.game_type_string = Event.pretty_game_type(self.game_type, false) if self.game_type 

			self.team = Team.find(self.team_id) if self.team_id
		else
			self.title = DEFAULT_TITLE
		end
		self.id = DEFAULT_ID
	end

	def team
		nil
	end

	def rabl_cache_key
		self.cache_key
	end

	def cache_key
		"NullEvent/#{self.id}/#{self.title}"
	end
end
