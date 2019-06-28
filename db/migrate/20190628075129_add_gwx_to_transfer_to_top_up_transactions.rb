class AddGwxToTransferToTopUpTransactions < ActiveRecord::Migration[5.2]

  def change
    add_column :top_up_transactions, :gwx_to_transfer, :decimal, precision: 8, scale: 6
  end

end
