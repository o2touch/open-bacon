# I separated this into a service, rahter than putting it on the model,
#  because I can easily see checkins becoming more complex in due course
#  with their own model, and loads of other shit. This should make the
#  refactor a little easier. Also all existing TSE shit is disgusting!
#  TS
class TeamsheetEntriesService
  class << self

    def check_in(tse)
      tse.checked_in = true
      tse.checked_in_at = Time.now
      tse.save!
    end

    def check_out(tse)
      tse.checked_in = false
      tse.checked_in_at = nil
      tse.save!
    end

    # invite response stuff
    def set_availability(tse, availability, set_by=nil)
      return if tse.response_status == availability

      set_by = tse.user if set_by.nil?

      ir = tse.invite_responses.create!({
        response_status: availability,
        created_by: set_by
      })
      ir.push_create_to_feeds
      
      ir
    end

    def reset_availability(tse)
      ir = tse.invite_responses.create!({
        response_status: AvailabilityEnum::NOT_RESPONDED,
        created_by: nil
      })
    end
  end
end