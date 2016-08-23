require 'spec_helper'

describe Queueable, broken: true do
	# shit to create and drop a dummy table that is required because the
	# module requires active record shit...
  before :all do
    m = ActiveRecord::Migration
    m.verbose = false  
    m.create_table :queueable_dummy_classes do |t| 
      t.integer :status
      t.integer :attempts
      t.timestamp :processed_at
      t.text :ers
    end
  end

  after :all do
    m = ActiveRecord::Migration
    m.verbose = false
    m.drop_table :queueable_dummy_classes
  end

	class QueueableDummyClass < ActiveRecord::Base
		include Queueable
		serialize :ers, Array

		def run
			true
		end
	end

	context 'class methods' do
		# TODO: the state doesn't get reset after I fuck about with it in these tests,
		# so lots below fail. Not sure how to test this. TS
		#
		# describe 'queueable' do
		# 	it 'populates the @worker var' do
		# 		@double = double("worker")
		# 		QueueableDummyClass.queueable(worker: @double)
		# 		QueueableDummyClass.worker.should eq(@double)
		# 	end
		# 	it 'populates the @run_method var' do
		# 		@double = double("worker")
		# 		QueueableDummyClass.queueable(run_method: @double)
		# 		QueueableDummyClass.run_method.should eq(@double)
		# 	end
		# end

		describe 'run' do
			before :each do
				@q = QueueableDummyClass.new
				@q.stub(processable?: true)
				QueueableDummyClass.stub(find: @q)
				QueueableDummyClass.stub(:delete)
			end
			it 'does not run unless resource is processable?' do
				@q.should_receive(:processable?).and_return(false)
				@q.should_not_receive(:update_attribute)
				QueueableDummyClass.run(1)
			end
			it 'updates status to PROCESSING while it is processing' do
				@q.should_receive(:update_attribute).with(:status, QueueItemStatusEnum::PROCESSING)
				@q.should_receive(:update_attribute).with(:processed_at, kind_of(Time))
				@q.should_receive(:update_attribute).with(:status, QueueItemStatusEnum::DONE)
				QueueableDummyClass.run(1)
			end
			it 'exits with status filtered if filter? is defined and returns true' do
				@q.should_receive(:filter?).and_return(true)
				QueueableDummyClass.run(1)
				@q.status.should eq(QueueItemStatusEnum::FILTERED)
			end
			it 'continues processing if filter? is defined and returns false' do
				@q.should_receive(:filter?).and_return(false)
				QueueableDummyClass.run(1)
				@q.status.should eq(QueueItemStatusEnum::DONE)
			end
			it 'is hap even if filter? is not defined' do
				# having nothing receive :filter? here means it's not defined
				QueueableDummyClass.run(1)
				@q.status.should eq(QueueItemStatusEnum::DONE)
			end
			it 'exits with status QUEUED, attempts +=1 if ready? is defined and returns false' do
				@q.attempts = 1
				@q.should_receive(:ready?).and_return(false)
				@q.should_receive(:process)
				QueueableDummyClass.run(1)
				@q.status.should eq(QueueItemStatusEnum::QUEUED)
				@q.attempts.should eq(2)
			end
			it 'continues processing if ready? is defined and returns true' do
				@q.should_receive(:ready?).and_return(true)
				QueueableDummyClass.run(1)
				@q.status.should eq(QueueItemStatusEnum::DONE)
			end
			it 'is hap even if ready? is not defined' do
				# having nothing to receive :ready? here means it's not defined
				QueueableDummyClass.run(1)
				@q.status.should eq(QueueItemStatusEnum::DONE)
			end
			it 'sends @run method to the resource' do
				@q.should_receive(QueueableDummyClass.run_method)
				QueueableDummyClass.run(1)
			end
			it 'exits with status ERRORED if run_method throws' do
				@q.should_receive(QueueableDummyClass.run_method).and_raise
				lambda{ QueueableDummyClass.run(1) }.should raise_exception
				@q.status.should eq(QueueItemStatusEnum::ERRORED)
				@q.ers.length.should eq(2)
			end
			it 'exits with status DONE if run_method returns true' do
				@q.should_receive(QueueableDummyClass.run_method).and_return(true)
				QueueableDummyClass.run(1)
				@q.status.should eq(QueueItemStatusEnum::DONE)
			end
			it 'exits with status REJECTED if run_method returns false' do
				@q.should_receive(QueueableDummyClass.run_method).and_return(false)
				QueueableDummyClass.run(1)
				@q.status.should eq(QueueItemStatusEnum::REJECTED)
			end
		end
	end

	context 'class_eval shit' do
		it 'sets set_status as a callback' do
			@q = QueueableDummyClass.new
			@q.should_receive(:set_status)
			@q.save
		end
		it 'sets set_attempts as a callback' do
			@q = QueueableDummyClass.new
			@q.should_receive(:set_attempts)
			@q.save
		end
		it 'sets a default value for @worker' do
			QueueableDummyClass.worker.should eq(Queueable::Worker)
		end
		it 'sets a default value for @run_method' do
			QueueableDummyClass.run_method.should eq(:run)
		end
	end

	describe 'set_status' do
		it 'should set the status to QueueItemStatusEnum::QUEUED' do
			@q = QueueableDummyClass.new
			@q.status.should be_nil
			@q.set_status
			@q.status.should eq(QueueItemStatusEnum::QUEUED)
		end
	end

	describe 'set_attempts' do
		it 'should set the attempts to 0' do
			@q = QueueableDummyClass.new
			@q.attempts.should be_nil
			@q.set_attempts
			@q.attempts.should eq(0)
		end
	end

	describe 'is_queueable?' do
		it 'should return true' do
			QueueableDummyClass.new.is_queueable?.should be_true
		end
	end

	describe 'process' do
		before :each do
			@q = QueueableDummyClass.new
			@q.stub(id: 4)
		end
		it 'should call perform_async on the worker if attempts = 0' do
			@q.attempts = 0
			QueueableDummyClass.worker.should_receive(:perform_async).with(QueueableDummyClass.name, 4)
			QueueableDummyClass.worker.should_not_receive(:perform_in)
			@q.process
		end
		it 'should call perform_in on the worker if attempts > 0' do
			@q.attempts = 1
			QueueableDummyClass.worker.should_receive(:perform_in).with(2, QueueableDummyClass.name, 4)
			QueueableDummyClass.worker.should_not_receive(:perform_async)
			@q.process
		end
	end

	describe 'status convenience methods' do
		before :each do
			@ni = QueueableDummyClass.new
		end
		it 'should return false if status is done' do
			@ni.status = QueueItemStatusEnum::DONE
			@ni.done?.should be_true
			@ni.finished_processing?.should be_true
			@ni.processable?.should be_false
		end
		it 'should return false if status is rejected' do
			@ni.status = QueueItemStatusEnum::REJECTED
			@ni.done?.should be_false
			@ni.finished_processing?.should be_true
			@ni.processable?.should be_false
		end
		it 'should return false if status is processing' do
			@ni.status = QueueItemStatusEnum::PROCESSING
			@ni.done?.should be_false
			@ni.finished_processing?.should be_false
			@ni.processable?.should be_false
		end
		it 'should return false if status is filtered' do
			@ni.status = QueueItemStatusEnum::FILTERED
			@ni.done?.should be_false
			@ni.finished_processing?.should be_true
			@ni.processable?.should be_true
		end
		it 'should return true if status is ERRORED' do
			@ni.status = QueueItemStatusEnum::ERRORED
			@ni.done?.should be_false
			@ni.finished_processing?.should be_false
			@ni.processable?.should be_true
		end
		it 'should return false if status is processable' do
			@ni.status = QueueItemStatusEnum::QUEUED
			@ni.done?.should be_false
			@ni.finished_processing?.should be_false
			@ni.processable?.should be_true
		end
	end
end