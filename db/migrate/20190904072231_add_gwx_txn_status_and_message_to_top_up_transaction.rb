class AddGwxTxnStatusAndMessageToTopUpTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :top_up_transactions, :gwx_transaction_message, :string
    add_column :top_up_transactions, :gwx_transaction_status, :string
  end
end
