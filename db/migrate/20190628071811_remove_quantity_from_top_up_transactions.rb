class RemoveQuantityFromTopUpTransactions < ActiveRecord::Migration[5.2]

  def change
    remove_column :top_up_transactions, :quantity
  end

end
