class EventResult < ActiveRecord::Base
  attr_accessible :score_against, :score_for
  
  belongs_to :event
  has_many :activity_items, :as => :obj

  after_save :touch_via_cache
  before_destroy { |x| x.touch_via_cache(Time.now) }

  def touch_via_cache(time=self.updated_at)
  	self.event.updated_at = time.utc
  	self.event.touch_via_cache(time)
  	return true
  end

  def update_result(score_for, score_against, current_user)
    old_score_for = self.score_for
    old_score_against = self.score_against

    unless (score_for.blank? || score_against.blank?) || (score_for == old_score_for && score_against == old_score_against)
      self.update_attributes! score_for: score_for, score_against: score_against

      meta_data = {
        :score_for => [old_score_for.to_s, self.score_for.to_s],
        :score_against => [old_score_against.to_s, self.score_against.to_s]
      }.to_json

      self.push_result_update_to_feeds(meta_data, current_user)
    end
  end

  def push_result_update_to_feeds(meta_data=nil, current_user)
    activity_item = ActivityItem.new
    activity_item.subj = current_user
    activity_item.obj = self
    activity_item.meta_data = meta_data
    activity_item.verb = :updated
    activity_item.save!

    activity_item.push_to_activity_feed(self.event)
    activity_item.push_to_profile_feed(self.event.team)
  end

  def won?
    (score_against.nil? || score_for.nil? || score_against =~ /\D/ || score_for =~ /\D/) ? nil : score_against.to_i < score_for.to_i
  end

  def draw?
    self.won? == nil ? nil : score_against.to_i == score_for.to_i
  end

  def lost?
    self.won? == nil ? nil : !(self.won? || self.draw?)
  end
end

