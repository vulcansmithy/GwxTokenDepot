class AddRealTimeRates < ActiveRecord::Migration[5.2]
  def change
    create_table :real_time_rates do |t|
      t.decimal :btc_rate, percision: 10
      t.decimal :eth_rate, percision: 10
      t.decimal :xem_rate, percision: 10
      t.timestamp :real_time_at
    end
  end
end
