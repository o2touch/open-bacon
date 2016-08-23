class EventPresenter < Draper::Decorator

	delegate_all

	def display_result?
		!object.is_cancelled? && !object.is_postponed? && (object.fixture.nil? || (!object.fixture.nil? && !object.fixture.result.nil?))
	end

	def display_time?
		object.time >= Time.now
	end
	alias_method :display_structured_data?, :display_time?

	def display_awaiting_result?
		!display_result? && ! display_time?
	end

	def display_event?
		return false if object.nil?
		if object.time >= Time.now
			return true
		elsif object.time >= (Time.now - 7.days)
			return !object.is_cancelled? && !object.is_postponed? 
		else
		 	return (object.fixture.nil? || (!object.fixture.nil? && !object.fixture.result.nil?)) && !object.is_cancelled? && !object.is_postponed? 
		end
	end

end