class AddBip32AddressPathToTopUpTransactions < ActiveRecord::Migration[5.2]
  def change
    add_column :top_up_transactions, :bip32_address_path, :string
  end
end
