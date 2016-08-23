class ChangeColumnTypeForScoreForAndScoreAgainstOnEventResult < ActiveRecord::Migration
  def change
  	change_column :event_results, :score_for, :string
  	change_column :event_results, :score_against, :string
  end
end
