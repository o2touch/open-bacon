class CreateSmsReplies < ActiveRecord::Migration
  def change
    create_table :sms_replies do |t|

      t.string :number
      t.string :content
      t.integer :teamsheet_entry_id
      
      t.timestamps
    end
  end
end
