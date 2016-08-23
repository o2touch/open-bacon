class AddScheduleLastSentToTeam < ActiveRecord::Migration
  def change
  	add_column :teams, :schedule_last_sent, :datetime
  end
end
