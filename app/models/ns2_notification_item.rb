class Ns2NotificationItem < ActiveRecord::Base
	include Queueable
	include Tenantable

	belongs_to :user
	belongs_to :app_event

	serialize :meta_data
	serialize :ers, Array

	attr_accessible :user, :app_event, :meta_data, :datum, :medium, :tenant

	validates :user, :datum, :app_event, :medium, :status, :tenant, presence: true

	before_validation :set_medium, :on => :create # should be implemented by subclasses

	# subclasses should include the following as well...
	#  (run method get stored on this class, and worker on the subclasses,
	#   prob should use class vars, rather than class instance vars, innit...)
	queueable worker: Ns2NotificationItemWorker, run_method: :deliver

end