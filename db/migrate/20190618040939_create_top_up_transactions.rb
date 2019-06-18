class CreateTopUpTransactions < ActiveRecord::Migration[5.2]
  def change
    create_table   :top_up_transactions do |t|
      t.string     :aasm_state
      
      t.timestamps null: false 
    end
  end
end
