######
# Includes ting to makes it easy to store settings on any model.
# 
# A model that includes this module can then have settings saved and retrieved
#  as follows:
#
#  # set setting
#  team.config.my_setting = "hi" 
#  # retrieve setting
#  team.config.my_setting 
#   => "hi"
#
#
# A parent can be optionally set, which will be checked for settings if
#  the model that is checked does not have it set. If the model has it
#  then it's parent will not be checked.
# 
# Set a parent as follows:
#
#  team.configurable_set_parent(division) # set div as team's parent
# 
#
# To delete a setting, set it to nil and the key will be removed.
#
#
# To use on a model include this module and a line as follows, where settings_hash:
#  is the name of the attr to store the settings in, and parent: is a polymorphic
#  attr for the parent.
#
#  # Setup Configuring Settings
#  configurable settings_hash: :configurable_settings_hash, parent: :configurable_parent
#
#
# Note settings are not saved automatically save should be called on the object owning the
#  hash if you want to save your changes!
#
# 
# TS
#
# TODO: 
#  - method to lock children, instead of manually setting that
#  - raise if parent is not configurable
#  - validate setup options
#  - allow nested settings
#  - do caching
#  - nicer method names
#  - script/rake task to add columns to models
#  - lazy load the parent
# 
##############

module Configurable
	class ConfigurableError < StandardError; end

	# this is where we do our magic
	class Settings
		def initialize(settings_hash, parent=nil)
			@hash = settings_hash
			@parent = parent
		end

		def method_missing(method, *args, &block)
			method_s = method.to_s
			set_setting(method.to_s[0..-2].to_sym, args) if method_s.ends_with? "="
			get_setting(method, args) unless method_s.ends_with? "="
		end

		def clear_all!
			@hash.clear
		end

		# def respond_to?(sym, include_private=false)
		# 	# this makes me feel weird, but technically it's the case
		# 	true
		# 	#super(sym, include_private)
		# end

		private
		def has_parent?
			!@parent.nil?
		end

		def set_setting(name, args)
			raise ArgumentError.new("wrong number of arguments #{args.count} for 1") unless args.count == 1

			# check settings aren't locked
			# TODO: make this less shit.
			if !@parent.nil? && @parent.configurable_settings.send(:children_locked)
				raise ConfigurableError.new("settings for this resource are locked")
			end

			arg = args[0]

			# remove if something is set to nil
			if arg.nil?
				@hash.delete(name) and return if @hash.has_key? name
			# else find dat ting
			else
				@hash[name] = arg
			end
		end

		# return the setting, if present
		def get_setting(name, args)
			raise ArgumentError.new("wrong number of arguments #{args.count} for 0") unless args.count == 0

			return @hash[name] if @hash.has_key? name
			return @parent.configurable_settings.send(name) unless @parent.nil?
			nil
		end

	end

	module ClassMethods

		def configurable(options={})
			# the name of the attribute that contains the settings has
			@configurable_hash_attr = options[:settings_hash] if options.has_key? :settings_hash
			# the name of the attr that is the models parent, in terms of settings shit
			@configurable_parent_attr = options[:parent] if options.has_key? :parent

			# TODO: validate the above

			serialize @configurable_hash_attr, Hash
			belongs_to @configurable_parent_attr, polymorphic: true unless @configurable_parent_attr.nil?
		end

		def configurable_hash_attr
			@configurable_hash_attr
		end

		def configurable_parent_attr
			@configurable_parent_attr
		end
	end

	def self.included(klazz)
		klazz.class_eval do
			@configurable_hash_attr = :configurable_settings_hash
			@configurable_parent_attr = nil
		end

		# swapped to below, as everything (currently) has settings attrs!
		#alias_method :settings, :configurable_settings unless method_defined? :settings
		alias_method :config, :configurable_settings unless method_defined? :config
		klazz.extend(ClassMethods)
	end

	def configurable_settings
		begin
			hash = self.send(self.class.configurable_hash_attr)
			parent = self.send(self.class.configurable_parent_attr) unless self.class.configurable_parent_attr.nil?
			Settings.new(hash, parent)
		rescue
			puts self.class.name
			puts self.to_yaml
		end
	end

	def configurable_set_parent(parent)
		raise ConfigurableError.new("#{self.class} not setup for parents") if self.class.configurable_parent_attr.nil?

		self.send("#{self.class.configurable_parent_attr.to_s}=", parent)
	end

	def configurable_delete_parent
		self.send("#{self.class.configurable_parent_attr.to_s}=", nil) unless self.class.configurable_parent_attr.nil?
	end
end
