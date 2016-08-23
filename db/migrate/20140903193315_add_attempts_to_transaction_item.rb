class AddAttemptsToTransactionItem < ActiveRecord::Migration
  def change
    add_column :transaction_items, :attempts, :integer
  end
end
