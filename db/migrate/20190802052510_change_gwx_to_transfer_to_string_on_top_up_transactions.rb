class ChangeGwxToTransferToStringOnTopUpTransactions < ActiveRecord::Migration[5.2]
  def change
    change_column :top_up_transactions, :gwx_to_transfer, :string
  end
end
