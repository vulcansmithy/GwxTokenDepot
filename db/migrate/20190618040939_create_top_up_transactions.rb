class CreateTopUpTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table   :top_up_transactions do |t|
      t.integer    :user_id
      t.decimal    :top_up_quantity,  precision: 10, scale: 6
      t.integer    :transaction_type, :null => true
      t.string     :top_up_receiving_wallet_address
      t.string     :top_up_transaction_hash
      t.datetime   :top_up_transaction_at
      
      t.string     :gwx_wallet_address
      t.string     :gwx_transaction_hash
      t.datetime   :gwx_transaction_at
      
      t.string     :aasm_state
      
      t.timestamps null: false 
    end
  end
end
