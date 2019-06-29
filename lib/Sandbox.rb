require "bitcoin"
require "faker"
require "sidekiq/api"

=begin
  - https://bitcoin.stackexchange.com/questions/43283/ruby-how-do-i-create-a-wallet-and-import-an-electrum-seed-using-money-tree-gem
  - https://stackoverflow.com/questions/48064914/how-to-check-a-bitcoin-wallet-balance-from-first-generated-address-m-44-0-0?rq=1
  - https://github.com/blockchain/api-v1-client-ruby/blob/master/docs/blockexplorer.md
  - https://www.blockcypher.com
  - https://github.com/mhanne/bitcoin-ruby-wallet/blob/master/spec/wallet/wallet_spec.rb
  - https://www.youtube.com/watch?v=IV9pRBq5A4g
  - https://stackoverflow.com/questions/48064914/how-to-check-a-bitcoin-wallet-balance-from-first-generated-address-m-44-0-0
  - https://www.blockonomics.co/views/api.html#limits
  - https://blockcypher.github.io/documentation/
  - https://makandracards.com/makandra/29437-enqueue-sidekiq-jobs-dynamically
=end

class Sandbox
  
=begin  
  def wb1
    # seed_hex = "d3bd6fed7767dd5bf9649216fe0e4668f2e0672aa694b174bd279dc2ee428523"
    
    master = MoneyTree::Master.new network: :bitcoin_testnet
    puts "master.seed... #{master.seed}"
    
    node = nil
    10.times do |i|
      node = master.node_for_path "m/0/0/#{i}"
      puts "BIP32 m/0/0/#{i                     }"  
      puts "index..... #{node.index             }"
      puts "depth..... #{node.depth             }"
      puts "address... #{node.to_address        }"
      puts "Pub Key... #{node.to_bip32          }"
      puts "Prv Key... #{node.to_bip32(:private)}"
      puts
    end
  end

  def wb2
    seed_hex = "d3bd6fed7767dd5bf9649216fe0e4668f2e0672aa694b174bd279dc2ee428523"
    master   = MoneyTree::Master.new(network: :bitcoin_testnet, seed_hex: seed_hex)
    puts "@DEBUG L:#{__LINE__}   #{ap master.to_address(network: :bitcoin_testnet)}"
    
    node = master.node_for_path "m/0"
    puts "BIP32 m/0"
    puts "index..... #{node.index             }"
    puts "depth..... #{node.depth             }"
    puts "address... #{node.to_address(network: :bitcoin_testnet)}"
    puts "Pub Key... #{node.to_bip32(network: :bitcoin_testnet)}"
    puts "Prv Key... #{node.to_bip32(:private, network: :bitcoin_testnet)}"
    puts
#    puts "@DEBUG L:#{__LINE__}   #{node.to_serialized_hex(network: :bitcoin_testnet)}"
    # -> 043587cf015e8313a600000000c1ed243f197eae141978f39a8e99173798f1cc5bb39ffa153bd6391277d7e67902ed9332079cce44e6296ad10c27591c56249eda0c9df54e1d00edc059ec813fde

#    puts "@DEBUG L:#{__LINE__}   #{node.to_serialized_hex(:private, network: :bitcoin_testnet)}"
    # -> 04358394015e8313a600000000c1ed243f197eae141978f39a8e99173798f1cc5bb39ffa153bd6391277d7e6790058e12a0b3cdb9e6ce2280e2593535e234f4da4f2d6943c8c2fd6667103f48d0f
    
    puts "#{node.private_key}"  
    
    return node.to_bip32(:private, network: :bitcoin_testnet)
  end  

  def wb3(use_testnet=false)
    
    Bitcoin.network = :testnet3 if use_testnet
     
    key = Bitcoin::Key.generate
    public_key  = key.pub
    private_key = key.priv
    btc_wallet  = key.addr
    
    puts "BTC Wallet Address ... '#{btc_wallet }'"
    puts "BTC Private Key....... '#{private_key}'"
    puts "BTC Public Key........ '#{public_key }'"
  end

  def wb4
    master = MoneyTree::Master.new
    master_private_key = master.to_bip32(:private)
    master_public_key  = master.to_bip32

    puts "master public  key... #{master_public_key }"    
    puts "master private key... #{master_private_key}"

    @node = MoneyTree::Node.from_bip32(master_private_key)
      
    i = 0
    20.times do
      @child = @node.node_for_path "m/0/#{i}"
      puts @child.depth
      puts @child.index
      puts @child.to_address
      puts @child.to_bip32
      puts @child.to_bip32(:private)
      puts
      i+= 1
    end
  end 

  def wb5
  
    master = MoneyTree::Master.new(network: :bitcoin_testnet)
    master_wallet_address = master.to_address(network: :bitcoin_testnet)
    master_private_key    = master.to_bip32(:private, network: :bitcoin_testnet)
    master_public_key     = master.to_bip32(network: :bitcoin_testnet)

    puts "master wallet address... #{master_wallet_address}"
    puts "master public  key...... #{master_public_key }"    
    puts "master private key...... #{master_private_key}"
  

    @node = MoneyTree::Node.from_bip32(master_private_key)
#   @node = MoneyTree::Node.from_bip32("tprv8ZgxMBicQKsPf28ydAVh8ty4rbda272YFzGfmWwHufNaqDKTHJ8gSyKQMJ5E5fzqBVixXh7QZZXu7PfYdJoWi9gW5oWubBx2fSaFyZhN2YQ")
   
#   master_wallet_address = @node.to_address(network: :bitcoin_testnet)
#   master_private_key    = @node.to_bip32(:private, network: :bitcoin_testnet)
#   master_public_key     = @node.to_bip32(network: :bitcoin_testnet)
#   puts "master wallet address... #{master_wallet_address}"
#   puts "master public  key...... #{master_public_key }"    
#   puts "master private key...... #{master_private_key}"
      
    i = 0
    20.times do
      @child = @node.node_for_path "m/0/#{i}"
      puts @child.depth
      puts @child.index
      puts @child.to_address(network: :bitcoin_testnet)
      puts @child.to_bip32(network: :bitcoin_testnet)
      puts @child.to_bip32(:private, network: :bitcoin_testnet)
      puts @child.private_key
      puts
      i+= 1
    end
  end   

  def wb6
    payload = {
      body: {
                   user_id: 999,
                  quantity_to_receive: Faker::Number.decimal(3, 6).to_f,
          transaction_type: "btc",
        gwx_wallet_address: "T#{Faker::Blockchain::Bitcoin.address.upcase}"
      }
    }

    response = HTTParty.post("http://localhost:3000//top_up_transactions.json", payload)
    puts "@DEBUG L:#{__LINE__}   response.code: #{response.code}"
  end

  def wb7
    scheduled_set = Sidekiq::ScheduledSet.new
    puts "@DEBUG L:#{__LINE__}   scheduled_set.size: #{scheduled_set.size}"
    
    retry_set = Sidekiq::RetrySet.new
    puts "@DEBUG L:#{__LINE__}   retry_set.size: #{retry_set.size}"
    
    dead_set = Sidekiq::DeadSet.new
    puts "@DEBUG L:#{__LINE__}   dead_set.size: #{dead_set.size}"
  end  

  def wb8
    from = Time.zone.parse("2019-06-25 00:00:00 UTC")
    puts "@DEBUG L:#{__LINE__}   from: #{from}"
    
    to = from + 5.hours
    puts "@DEBUG L:#{__LINE__}     to: #{to}"
    
    Timecop.travel(Time.zone.parse("2019-06-25 05:00:00 UTC"))  do
      now = Time.zone.now
      
      result = (from..to).cover?(now)
      puts "@DEBUG L:#{__LINE__}   result: #{result}"
    end  
  end

  def wb9
    master_private_key = Rails.application.secrets.btc_master_private_key
    parent_node = MoneyTree::Node.from_bip32(master_private_key)
    
    child_node = parent_node.node_for_path("m/0/0")
    testnet_wallet_address = child_node.to_address(network: :bitcoin_testnet)
    mainnet_wallet_address = child_node.to_address
    
    puts "@DEBUG L:#{__LINE__}   testnet_wallet_address: #{testnet_wallet_address}"
    puts "@DEBUG L:#{__LINE__}   mainnet_wallet_address: #{mainnet_wallet_address}"
    
    wallet_address = 
      if Rails.env.production?
        child_node.to_address
      else
        child_node.to_address(network: :bitcoin_testnet)
      end  
        
    
    puts "@DEBUG L:#{__LINE__}   wallet_address: #{wallet_address}"
  end

  def wb10
    # BlockCypher API Token:  b66d04c1270a4bb1945eecf0e6daf101
    block_cypher = BlockCypher::Api.new({
      api_token: "b66d04c1270a4bb1945eecf0e6daf101",
      currency: BlockCypher::BTC,
      network:  BlockCypher::TEST_NET_3,
      version:  BlockCypher::V1
    })

#   wallet_address = "miPysba1zbz5qQsffYC4QW2N52LnGDdrCN" 
    wallet_address = "mfmrZxLwnoSat8FXR7Aw24CwmJmeL6sDDB" 
#   wallet_address = "n3gHHZsXg9z3Rj8F3JeBDTxWcR5XCmzdBg" 
#   wallet_address = "mnoVoXEC7LaE9Xgf7soX8a6bnaUCZYo46D"
    result         = block_cypher.address_details(wallet_address)

    return result
  end

  def wb11
    transaction_value = 10001000
        satochi_value = transaction_value * 1000
    puts "@DEBUG L:#{__LINE__}   satochi_value: #{satochi_value}"
    
    satochi_converter =Satoshi.new(satochi_value, from_unit: :satoshi)
    puts "@DEBUG L:#{__LINE__}   Converted: #{satochi_converter.to_btc}"
  end

  def wb12
    explorer = Blockchain::BlockExplorer.new("'https://testnet.blockchain.info", "Code: 62b1b01a-63d0-4788-b818-9fa5c961e759")
  end

  def wb13
#   response = HTTParty.get("https://blockchain.info/rawaddr/1Nh7uHdvY6fNwtQtM1G5EZAFPLC33B59rB?api_code=62b1b01a-63d0-4788-b818-9fa5c961e759")
#   response = HTTParty.get("https://testnet.blockchain.info/rawaddr/mfmrZxLwnoSat8FXR7Aw24CwmJmeL6sDDB?api_code=62b1b01a-63d0-4788-b818-9fa5c961e759")
#   response = HTTParty.get("https://api.blockcypher.com/v1/btc/test3/address/mfmrZxLwnoSat8FXR7Aw24CwmJmeL6sDDB")
#   response = HTTParty.get("https://test.blockchain.com/btctest/address/miPysba1zbz5qQsffYC4QW2N52LnGDdrCN?api_code=62b1b01a-63d0-4788-b818-9fa5c961e759")
#   response = HTTParty.get("https://api.blockcypher.com/v1/btc/test3/addrs/n3gHHZsXg9z3Rj8F3JeBDTxWcR5XCmzdBg/full")

    # >>> THIS WORKS!!! <<<
    # response = HTTParty.get("https://chain.so/api/v2/get_address_balance/BTCTEST/mfmrZxLwnoSat8FXR7Aw24CwmJmeL6sDDB")
  
    # >>> THIS WORKS!!! <<<
    response = HTTParty.get("https://chain.so/api/v2/get_address_balance/BTC/1EbLHdwKndhjYVY9x9WgWBmJy5dJuXPPMi")
  end
  
  def wb14
    wb14_1
    wb14_2
    wb14_3
    wb14_4
    wb14_5
  end
  
  def wb14_1
    wallet = "miPysba1zbz5qQsffYC4QW2N52LnGDdrCN"   # 0.05775990
    
    ###
    ###
    gwx_wallet = "#{Faker::Blockchain::Bitcoin.address.upcase}"
    payload = {
      body: {
                    user_id: 101,
        quantity_to_receive: 0.05775990,
            gwx_to_transfer: 10.0,
           transaction_type: "btc",
         gwx_wallet_address: gwx_wallet
      }
    }

    response = HTTParty.post("http://localhost:3000//top_up_transactions.json", payload)
    puts "@DEBUG L:#{__LINE__}   response.code: #{response.code}"
    
    transaction = TopUpTransaction.where(gwx_wallet_address: gwx_wallet).first
    transaction.top_up_receiving_wallet_address = wallet
    raise "transaction.save failed" unless transaction.save
  end
  
  def wb14_2
    wallet = "mfmrZxLwnoSat8FXR7Aw24CwmJmeL6sDDB"   # 0.07545732
    
    ###
    ###
    gwx_wallet = "#{Faker::Blockchain::Bitcoin.address.upcase}"
    payload = {
      body: {
                    user_id: 101,
        quantity_to_receive: 0.07545732,
            gwx_to_transfer: 20.0,
           transaction_type: "btc",
         gwx_wallet_address: gwx_wallet
      }
    }

    response = HTTParty.post("http://localhost:3000//top_up_transactions.json", payload)
    puts "@DEBUG L:#{__LINE__}   response.code: #{response.code}"
    
    transaction = TopUpTransaction.where(gwx_wallet_address: gwx_wallet).first
    transaction.top_up_receiving_wallet_address = wallet
    raise "transaction.save failed" unless transaction.save
  end

  def wb14_3
    wallet = "n3gHHZsXg9z3Rj8F3JeBDTxWcR5XCmzdBg"   # 0.00010001
    
    ###
    ###
    gwx_wallet = "#{Faker::Blockchain::Bitcoin.address.upcase}"
    payload = {
      body: {
                    user_id: 101,
        quantity_to_receive: 0.00010001,
            gwx_to_transfer: 30.0,
            transaction_type: "btc",
         gwx_wallet_address: gwx_wallet
      }
    }

    response = HTTParty.post("http://localhost:3000//top_up_transactions.json", payload)
    puts "@DEBUG L:#{__LINE__}   response.code: #{response.code}"
    
    transaction = TopUpTransaction.where(gwx_wallet_address: gwx_wallet).first
    transaction.top_up_receiving_wallet_address = wallet
    raise "transaction.save failed" unless transaction.save
  end
  
  def wb14_4
    wallet = "mnoVoXEC7LaE9Xgf7soX8a6bnaUCZYo46D"   # 0.01000000
    
    ###
    ###
    gwx_wallet = "#{Faker::Blockchain::Bitcoin.address.upcase}"
    payload = {
      body: {
                    user_id: 101,
        quantity_to_receive: 0.01000000,
            gwx_to_transfer: 40.0,
           transaction_type: "btc",
         gwx_wallet_address: gwx_wallet
      }
    }

    response = HTTParty.post("http://localhost:3000//top_up_transactions.json", payload)
    puts "@DEBUG L:#{__LINE__}   response.code: #{response.code}"
    
    transaction = TopUpTransaction.where(gwx_wallet_address: gwx_wallet).first
    transaction.top_up_receiving_wallet_address = wallet
    raise "transaction.save failed" unless transaction.save
  end
  
  def wb14_5
    wallet = "mpyGnwmJmp7vYP4q4o1kAqz7kEWKS9cGdE"
    
    ###
    ###
    gwx_wallet = "#{Faker::Blockchain::Bitcoin.address.upcase}"
    payload = {
      body: {
                    user_id: 101,
        quantity_to_receive: 0.12345678,
            gwx_to_transfer: 50.0,
          transaction_type: "btc",
        gwx_wallet_address: gwx_wallet
      }
    }

    response = HTTParty.post("http://localhost:3000//top_up_transactions.json", payload)
    puts "@DEBUG L:#{__LINE__}   response.code: #{response.code}"
    
    transaction = TopUpTransaction.where(gwx_wallet_address: gwx_wallet).first
    transaction.top_up_receiving_wallet_address = wallet
    raise "transaction.save failed" unless transaction.save
  end
=end
  
  def wb15
    response = HTTParty.get("https://chain.so/api/v2/get_price/BTC/USD")
  end  
  
  def wb16(btc_value)
    btc_to_usd_conversation_rate = 11903.10
    
    btc_in_usd = btc_value * btc_to_usd_conversation_rate
    gwx_value  = btc_in_usd / 0.003
  end
end