module Messageable
  def self.included(klazz)
    klazz.class_eval do
      has_many :messages, :as => :messageable, :class_name => "EventMessage", :order => 'created_at DESC'
    end
  end
  
  #Gets the mailbox of the messageable
  def mailbox
    @mailbox = Mailbox.new(self) if @mailbox.nil?
    @mailbox.type = :all
    return @mailbox
  end
  
  def acts_as_messagable?
    true
  end
end
