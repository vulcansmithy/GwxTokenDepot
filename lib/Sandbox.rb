require "bitcoin"

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
=end

class Sandbox
  
  def main
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

=begin  
  def workbench1
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
  
  def workbench2(use_testnet=false)
    
    Bitcoin.network = :testnet3 if use_testnet
     
    key = Bitcoin::Key.generate
    public_key  = key.pub
    private_key = key.priv
    btc_wallet  = key.addr
    
    puts "BTC Wallet Address ... '#{btc_wallet }'"
    puts "BTC Private Key....... '#{private_key}'"
    puts "BTC Public Key........ '#{public_key }'"
  end
=end
  
  def wb1
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
  
  def wb2
  
    master = MoneyTree::Master.new(network: :bitcoin_testnet)
    master_wallet_address = master.to_address(network: :bitcoin_testnet)
    master_private_key    = master.to_bip32(:private, network: :bitcoin_testnet)
    master_public_key     = master.to_bip32(network: :bitcoin_testnet)

    puts "master wallet address... #{master_wallet_address}"
    puts "master public  key...... #{master_public_key }"    
    puts "master private key...... #{master_private_key}"
  

    @node = MoneyTree::Node.from_bip32(master_private_key)
#   @node = MoneyTree::Node.from_bip32("tprv8ZgxMBicQKsPf28ydAVh8ty4rbda272YFzGfmWwHufNaqDKTHJ8gSyKQMJ5E5fzqBVixXh7QZZXu7PfYdJoWi9gW5oWubBx2fSaFyZhN2YQ")
   
=begin   
    master_wallet_address = @node.to_address(network: :bitcoin_testnet)
    master_private_key    = @node.to_bip32(:private, network: :bitcoin_testnet)
    master_public_key     = @node.to_bip32(network: :bitcoin_testnet)
    puts "master wallet address... #{master_wallet_address}"
    puts "master public  key...... #{master_public_key }"    
    puts "master private key...... #{master_private_key}"
=end    
      
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

end