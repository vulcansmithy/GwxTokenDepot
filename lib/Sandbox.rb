require "bitcoin"

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
    puts "@DEBUG L:#{__LINE__}   #{node.to_serialized_hex(network: :bitcoin_testnet)}"
    # -> 043587cf015e8313a600000000c1ed243f197eae141978f39a8e99173798f1cc5bb39ffa153bd6391277d7e67902ed9332079cce44e6296ad10c27591c56249eda0c9df54e1d00edc059ec813fde

    puts "@DEBUG L:#{__LINE__}   #{node.to_serialized_hex(:private, network: :bitcoin_testnet)}"
    # -> 04358394015e8313a600000000c1ed243f197eae141978f39a8e99173798f1cc5bb39ffa153bd6391277d7e6790058e12a0b3cdb9e6ce2280e2593535e234f4da4f2d6943c8c2fd6667103f48d0f
    
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
  
end