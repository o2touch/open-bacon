class CacheInviteResponsesCount < ActiveRecord::Migration
  def up
    execute "update teamsheet_entries set invite_responses_count=(select count(*) from invite_responses where teamsheet_entry_id=invite_responses.id)"
  end

  def down
  end
end
