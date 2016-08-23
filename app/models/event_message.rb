class EventMessage < ActiveRecord::Base  
  include CacheHelper

  belongs_to :user
  belongs_to :messageable, :polymorphic => true

  attr_accessible :text, :user, :messageable, :meta_data, :sent_as_role_type, :sent_as_role_id

  serialize :meta_data, Hash

  validates :text, :presence => true

  validates_length_of :text,
    :minimum => FieldValidation::MINIMUM_MESSAGE_LENGTH,
    :maximum => FieldValidation::MAXIMUM_MESSAGE_LENGTH,
    :allow_blank => false

  def activity_item
    fetch_from_cache "#{self.cache_key}/ActivityItem" do
      ActivityItem.where("obj_id = ? and obj_type = ?", self.id, self.class.name).first
    end
  end

  def recipient_user_ids
    self.meta_data['recipients']['users'] 
  end

  def recipient_group_ids
    self.meta_data['recipients']['groups']
  end

  def recipient_users
    self.recipients_hash_to_user(self.meta_data['recipients'])
  end

  # *** This method now returns juniors, as well as their parents. TS
  def recipients_hash_to_user(recipients_hash)
    return [] if recipients_hash.nil? or !recipients_hash.is_a? Hash

    groups = recipients_hash['groups']
    
    unless groups.nil? or groups.empty?
      groups = groups.map(&:to_i).reject {|z| z==0}
    end
    recipients = recipients_hash['users']

    users = []
    unless recipients.nil? or recipients.empty?
      recipients = recipients.map(&:to_i).reject {|z| z==0}
      users = recipients.map { |x| User.find(x) }
    end

    group_users = []
    group_parents = []

    if self.messageable.is_a?(Team)
      group_users = messageable.members
    else
      if groups.nil? or groups.empty?
        group_users = messageable.invitees
      else
        self.messageable.cached_teamsheet_entries.each do |teamsheet_entry|
          if (teamsheet_entry.response_status == InviteResponseEnum::UNAVAILABLE and groups.include?(MessageGroups::UNAVAILABLE)) or
            (teamsheet_entry.response_status == InviteResponseEnum::AVAILABLE and groups.include?(MessageGroups::AVAILABLE)) or
            (teamsheet_entry.response_status == InviteResponseEnum::NOT_RESPONDED and groups.include?(MessageGroups::AWAITING))
            group_users << teamsheet_entry.user
          end
        end
      end
    end
    group_parents = group_users.map { |x| x.junior? ? x.parents : nil }.flatten.compact

    users | group_users | group_parents
  end
end
