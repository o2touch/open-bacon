class EventsPresenter < Draper::CollectionDecorator
  	
	def decorator_class
		EventPresenter
	end

	def events
		objs = []
		decorated_collection.each do |e|
			objs << e if e.display_event?
		end
		return objs.sort_by { |c| c.time }
	end

end