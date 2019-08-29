class AddOutgoingIdtoTopUpTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :top_up_transactions, :outgoing_id, :int
  end
end
