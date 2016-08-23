######
# Includes methods to make a Rails model queueable and processable, using sidekiq
#  (or probs anything, with a little modification).
#
# A model that includes this module should have status and attempts columns,
#  both ints, and a method :run that does the actual processing of whatever
#  shit the ting does. (Though if required the run_method: my_method_name
#  can be passed to the queueable method, to use a different one)
# 
# It can optionally define a filter? method that returns true if the model
#   should not be processed.
#
# Also it can optionally define a ready? method, which returns false to delay
#   the processing of that unit of work.
#
# To define a custom worker (recommended) the model should call:
#     queueable worker => MySpecialWorkerClass
#   Alternatively a default worker will be used on a queue called:
#     queueable-default-queue
#
# Also, add :ers (as a serialized []) to store error messages
#
#  TS
#
###########

module Queueable
  module ClassMethods
		def run(id)
			resource = self.find(id)
			return unless resource.processable?
			resource.update_attribute(:status, QueueItemStatusEnum::PROCESSING)

			begin
				# allow the resource to define a filter? method, to stop it being processed
				if resource.respond_to?(:filter?) && resource.filter?
					resource.update_attribute(:status, QueueItemStatusEnum::FILTERED)
					return	
				end

				# subtley different from the above, status assumes it will be processed
				#  at some later time, whereas filter does not
				if resource.respond_to?(:defer?) &&resource.defer?
					resource.update_attribute(:status, QueueItemStatusEnum::WAITING)
					return
				end

				# allow the resource to define ready? 
				#  this is subtly different again. rather than just stopping processing
				#  the resource it scheduled for reprocessing in attempts^2 seconds
				if resource.respond_to?(:ready?) && !resource.ready?

					resource.status = QueueItemStatusEnum::QUEUED
					resource.attempts += 1
					resource.save!
					# process later
					resource.process
					return
				end

				processed = false
				# if something goes wrong this call should error, and be allowed to propogate up!
				processed = resource.send(@run_method)
			rescue Exception => e
				resource.update_attribute(:status, QueueItemStatusEnum::ERRORED)
				# save the error, if we can
				if resource.respond_to?(:ers)
					error = "Error processing #{resource.class.name} #{resource.id}: #{e.message}"
					resource.ers ||= []
					resource.ers << error
					resource.ers << e.backtrace	
					resource.save
				end
				raise e
			ensure
				resource.update_attribute(:processed_at, Time.now)
			end

			resource.update_attribute(:status, QueueItemStatusEnum::DONE) if processed
			resource.update_attribute(:status, QueueItemStatusEnum::REJECTED) unless processed
		end

		def queueable(options={})
			# store this shit in class instance vars,
			# TODO: check the worker is valid
			@worker = options[:worker] if options.has_key? :worker
			# TODO: check the run_method is valid
			@run_method = options[:run_method] if options.has_key? :run_method
		end

		# class method to access the worker
		def worker
			@worker
		end

		# class method to access the run method
		def run_method
			@run_method
		end
  end

  def self.included(klazz)
    klazz.class_eval do
    	# TOOD: create a migration for this shit if/when this gets put in a gem
     	attr_accessible :status, :attempts, :processed_at
			before_validation :set_status, :on => :create 
			before_validation :set_attempts, :on => :create 

			# TODO: put some validation in???

			# store the config in class instance vars
			@worker = Worker
			@run_method = :run
    end

    klazz.extend(ClassMethods)
  end

  # for callback
	def set_status
		self.status = QueueItemStatusEnum::QUEUED
	end

	# for callback
	def set_attempts
		self.attempts = 0
	end
	
	# check for done status
	def done? 
		self.status == QueueItemStatusEnum::DONE
	end

	# check it will not be processed in the future
	def finished_processing?
		self.status == QueueItemStatusEnum::FILTERED ||
			self.status == QueueItemStatusEnum::REJECTED ||
			self.status == QueueItemStatusEnum::DONE
	end

	def processable?
		self.status == QueueItemStatusEnum::QUEUED || 
			self.status == QueueItemStatusEnum::ERRORED ||
			self.status == QueueItemStatusEnum::FILTERED ||
			self.status == QueueItemStatusEnum::WAITING
	end

	# this basically just calls self.run, with sidekiq magic thrown in
	def process
		worker = self.class.worker

		# do it as soon as possible
		worker.perform_async(self.class.name, self.id) if self.attempts == 0

		# delay...
		worker.perform_in((2**self.attempts).seconds, self.class.name, self.id) if self.attempts > 0
	end

	def is_queueable?
		true
	end

end
