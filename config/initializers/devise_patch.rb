module Devise
  module Controllers
    module Helpers
    	# Minor change by TS to the original implementation
    	# (vendor/bundle/ruby/1.9.1/gems/devise-2.0.4/lib/devise/controllers/helpers.rb)
    	# to ensure that users with role NO_LOGIN cannot login
    	def sign_in(resource_or_scope, *args)
        options  = args.extract_options!
        scope    = Devise::Mapping.find_scope!(resource_or_scope)
        resource = args.last || resource_or_scope

        # added by TS to ensure users with role NO_LOGIN cannot log in.\
        if resource.respond_to? :role?
        	return false if resource.role? RoleEnum::NO_LOGIN
      	end 

        expire_session_data_after_sign_in!

        if options[:bypass]
          warden.session_serializer.store(resource, scope)
        elsif warden.user(scope) == resource && !options.delete(:force)
          # Do nothing. User already signed in and we are not forcing it.
          true
        else
          warden.set_user(resource, options.merge!(:scope => scope))
        end
      end
    end
  end
end