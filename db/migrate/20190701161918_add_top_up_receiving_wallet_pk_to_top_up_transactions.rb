class AddTopUpReceivingWalletPkToTopUpTransactions < ActiveRecord::Migration[5.2]

  def change
    add_column :top_up_transactions, :bip44_address_path, :string
  end
  
end
