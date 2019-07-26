class ChangeQuantityToReceiveToStringOnTopUpTransactions < ActiveRecord::Migration[5.2]
  def change
    change_column :top_up_transactions, :quantity_to_receive, :string
  end
end
