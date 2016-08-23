module ApplicationHelper

	def event_type_string(event_type)
		if event_type == "event"
			return "an event"
		elsif event_type == "game"
			return "a game"
		elsif event_type == "practice"
			return "a practice"
		end
	end
	
	def graceful_event(model)
		if model.respond_to?("event") and !model.event.nil?
			return model.event
		end

		versioned_event = VestalVersions::Version.where(
				:versioned_id => model.event_id, :versioned_type => "Event", :tag => "deleted"
			).order(:updated_at).last

		deleted_event_params = versioned_event.nil? ? nil : versioned_event.modifications

		NullEvent.new(deleted_event_params)
	end

	def graceful_activity_event(activity_item)
		return activity_item.obj if activity_item.respond_to?("obj") and !activity_item.obj.nil?

		versioned_event = VestalVersions::Version.where(
				:versioned_id => activity_item.obj_id, :versioned_type => "Event", :tag => "deleted"
			).order(:updated_at).last

		deleted_event_params = versioned_event.nil? ? nil : versioned_event.modifications

		NullEvent.new(deleted_event_params)
	end

	def filtered_activity_meta_data(meta_data)
		return meta_data if meta_data.nil?

		meta_data_hash = JSON.parse(meta_data)

		return meta_data unless meta_data_hash.is_a? Hash

		if meta_data_hash.has_key?('starred_at') and meta_data_hash['starred'] == false
			meta_data_hash.delete('starred_at')
		end
		meta_data_hash.delete('starred')

		return nil if meta_data_hash.empty?
		meta_data_hash.to_json
	end

	def global_application_context
		return BFFakeContext.new
	end

	# if a JS string contains "</script>" etc, it will close the current <script>
	def safe_js_string(js_string)
		return '' if js_string.nil?
		js_string.gsub('</','<\/').html_safe
	end

  # # Get the domain for a tenantable object
  # def get_tenant_domain(model)

  #   modules = model.class.ancestors.select {|o| o.class == Module}

  #   # We only need to do this for models which include the Tenantable module
  #   if modules.include?(Tenantable)
  #     method_model = model.class.model_name.underscore 
  #     return nil if model.send("is_mitoo_#{method_model}?") || model.tenant.nil?
      
  #     host = $ROOT_DOMAIN
  #     unless model.tenant.subdomain.blank?
  #       subdomain = model.tenant.subdomain 
  #       host = subdomain + "." + host
  #     end

  #     return host
  #   end

  #   nil
  # end

end
