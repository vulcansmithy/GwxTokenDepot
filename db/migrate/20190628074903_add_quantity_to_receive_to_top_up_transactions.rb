class AddQuantityToReceiveToTopUpTransactions < ActiveRecord::Migration[5.2]

  def change
    add_column :top_up_transactions, :quantity_to_receive, :decimal, precision: 10, scale: 8
  end
  
end
