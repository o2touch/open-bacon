class AppEvent < ActiveRecord::Base
  belongs_to :subj, :polymorphic => true
  belongs_to :obj, :polymorphic => true  

  attr_accessible :subj, :obj, :verb, :meta_data, :processed_at
  serialize :meta_data, Hash

  validates :subj, :presence => true
  validates :obj, :presence => true
  validates :verb, :presence => true

  def processed?
  	!self.processed_at.nil?
  end

  def process
    # work out what we expec the processor to be called.
    clazz = self.obj.class.to_s
    clazz += 's' unless clazz.last == 's'

    # TODO: check for obj being nil. (only an issue generally after the 
    #  processing has been delayed for some reason.
    processor = "Ns2::Processors::#{clazz}Processor"

    processor = self.meta_data[:processor] if self.meta_data.has_key? :processor

    Ns2AppEventWorker.perform_async(self.id, processor)
  end
end