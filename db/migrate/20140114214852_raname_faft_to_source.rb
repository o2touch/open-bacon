class RanameFaftToSource < ActiveRecord::Migration
  def change
  	rename_column :teams, :faft_id, :source_id
  	rename_column :leagues, :faft_id, :source_id
  	rename_column :divisions, :faft_id, :source_id
  	rename_column :fixtures, :faft_id, :source_id

  	add_column :teams, :source, :string
  	add_column :leagues, :source, :string
  	add_column :divisions, :source, :string
  	add_column :fixtures, :source, :string
  	add_column :points_adjustments, :source, :string

		ActiveRecord::Base.connection.execute("update fixtures set source='faft' where source_id is not null")
		ActiveRecord::Base.connection.execute("update teams set source='faft' where source_id is not null")
		ActiveRecord::Base.connection.execute("update leagues set source='faft' where source_id is not null")
		ActiveRecord::Base.connection.execute("update divisions set source='faft' where source_id is not null")
		ActiveRecord::Base.connection.execute("update points_adjustments set source='faft'")
  end
end
