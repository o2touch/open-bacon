class CreateSmsSents < ActiveRecord::Migration
  def change
    create_table :sms_sents do |t|

      t.string  :from
      t.integer :user_id
      t.string  :to
      t.string  :content
      t.integer :sms_reply_code
      t.integer :sms_reply_id
      t.integer :teamsheet_entry_id, :null => true
      
      t.timestamps
    end
  end
end
