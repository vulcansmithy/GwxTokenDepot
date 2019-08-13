namespace :wallet_generator do
  desc "Generate a btc HD Wallet"
  task :btc do
    master = MoneyTree::Master.new
    master_wallet_address = master.to_address
    master_private_key    = master.to_bip32(:private)
    master_public_key     = master.to_bip32

    node = MoneyTree::Node.from_bip32(master_private_key)
   
    master_wallet_address = node.to_address
    master_private_key    = node.to_bip32(:private)
    master_public_key     = node.to_bip32

    puts "master wallet address...: #{master_wallet_address}"
    puts "master public  key......: #{master_public_key    }"    
    puts "master private key......: #{master_private_key   }"
  end

  desc "Generate a ETH Wallet"
  task :eth do
    words = BipMnemonic.to_mnemonic(bits: 128)
    seed  = BipMnemonic.to_seed(mnemonic: words)
    first_wallet = Bip44::Wallet.from_seed(seed, "m/44'/60'/0'/0")
    xpub  = first_wallet.xpub  
    xprv  = first_wallet.xprv
    
    puts "Mnemonic Words............: #{words                        }"
    puts "Seed......................: #{seed                         }"
    puts "Ethereum Wallet Address...: #{first_wallet.ethereum_address}"
    puts "xpub......................: #{xpub                         }"
    puts "xprv......................: #{xprv                         }"
  end

end
