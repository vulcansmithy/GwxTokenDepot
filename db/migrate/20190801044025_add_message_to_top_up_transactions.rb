class AddMessageToTopUpTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :top_up_transactions, :message, :string
  end
end
