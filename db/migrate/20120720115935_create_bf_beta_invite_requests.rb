class CreateBfBetaInviteRequests < ActiveRecord::Migration
  def change
    create_table :bf_beta_invite_requests do |t|
      t.string :name
      t.string :email

      t.timestamps
    end
  end
end
