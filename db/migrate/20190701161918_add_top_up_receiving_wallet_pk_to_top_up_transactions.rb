class AddTopUpReceivingWalletPkToTopUpTransactions < ActiveRecord::Migration[5.2]

  def change
    add_column :top_up_transactions, :encrypted_top_up_receiving_wallet_pk,    :string
    add_column :top_up_transactions, :encrypted_top_up_receiving_wallet_pk_iv, :string
  end
  
end
