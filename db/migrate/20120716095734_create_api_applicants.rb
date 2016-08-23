class CreateApiApplicants < ActiveRecord::Migration
  def change
    create_table :api_applicants do |t|
      t.string :name
      t.string :email
      t.string :company

      t.timestamps
    end
  end
end
