require "nem"

class GwxCashierLib
  TIMEOUT = 15
  NODE_POOL =
    if Rails.env.production?
      Nem::NodePool.new([
        Nem::Node.new(host: '62.75.251.134', timeout: TIMEOUT),
        Nem::Node.new(host: '62.75.163.236', timeout: TIMEOUT),
        Nem::Node.new(host: '209.126.98.204', timeout: TIMEOUT),
        Nem::Node.new(host: '108.61.182.27', timeout: TIMEOUT),
        Nem::Node.new(host: '27.134.245.213', timeout: TIMEOUT),
        Nem::Node.new(host: '104.168.152.37', timeout: TIMEOUT),
        Nem::Node.new(host: '122.116.90.171', timeout: TIMEOUT),
        Nem::Node.new(host: '153.122.86.201', timeout: TIMEOUT),
        Nem::Node.new(host: '150.95.213.212', timeout: TIMEOUT),
        Nem::Node.new(host: '163.44.170.40', timeout: TIMEOUT),
        Nem::Node.new(host: '153.126.157.201', timeout: TIMEOUT),
        Nem::Node.new(host: '45.76.192.220', timeout: TIMEOUT)
      ])
    else
      Nem::NodePool.new([
        Nem::Node.new(host: '23.228.67.85', timeout: TIMEOUT),
        Nem::Node.new(host: '104.128.226.60', timeout: TIMEOUT),
        Nem::Node.new(host: '150.95.145.157', timeout: TIMEOUT),
        Nem::Node.new(host: '80.93.182.146', timeout: TIMEOUT),
        Nem::Node.new(host: '82.196.9.187', timeout: TIMEOUT),
        Nem::Node.new(host: '82.196.9.187', timeout: TIMEOUT),
        Nem::Node.new(host: '88.166.14.34', timeout: TIMEOUT)
      ])
    end

  MIN_XEM_BALANCE = 0.050000
  
  DEFAULT_SETTINGS = {
    network:         Rails.env.production? ? :mainnet : :testnet,
    hosts:           NODE_POOL,
    min_xem_balance: MIN_XEM_BALANCE,
    logger_level:    Logger::DEBUG,
  }
  
  def initialize(passed_params = {})
    @params = DEFAULT_SETTINGS.merge(passed_params)

    Nem.logger.level = @params[:logger_level]
    
    Nem.configure do |conf|
      conf.default_network = @params[:network]
    end

    @node = @params[:hosts]
  end

  def wallet_transfer(source_wallet_address, dest_wallet_address, source_wallet_pk, quantity)

    # get the current balance for xem and gwx
    mosaic_balance = xem_and_gwx_balance(source_wallet_address)
    xem_balance = mosaic_balance[:xem]
    gwx_balance = mosaic_balance[:gwx]
    
    # check if the wallet has gwx tokens
    if gwx_balance.nil?
      return {
        status:  "failed",
        message: "The provided source wallet doesn't have the corresponding gwx mosaic tokens."
      } 
    end  
      
    # check if the wallet has the minimum amount of xem  
    if xem_balance > @params[:min_xem_balance]
      if gwx_balance == 0
        return {
          status:  "failed",
          message: "The provided source wallet has 0 amount of gwx mosaic tokens."
        } 
      else
        transaction = Nem::Endpoint::Transaction.new(@node)
        transfer    = Nem::Transaction::Transfer.new(dest_wallet_address, 1, nil, timestamp: Time.now - 1000)
        
        # fetch mosaic definition
        namespace = Nem::Endpoint::Namespace.new(@node)
        mosaic_definition = namespace.mosaic_definition(Rails.env.production? ? "gameworks" : "gameworkss").first
        
        # setup mosaic attachment
        mosaic_attachment = Nem::Model::MosaicAttachment.new(
          mosaic_id:  mosaic_definition.id,
          properties: mosaic_definition.properties,
          quantity:   quantity
        )
        
        # attach mosaic_attachment 
        transfer.mosaics << mosaic_attachment
        
        key_pair = Nem::Keypair.new(source_wallet_pk)
        req      = Nem::Request::Announce.new(transfer, key_pair)
        res      = transaction.announce(req)
        
        # check if the transaction was successful
        if res.message.downcase == "success"
          return {
            status:             "success",
            message:            "Transaction successful.",
            transfered_amount:  quantity,
            transaction_hash:   res.transaction_hash,
            transfer_fee:       transfer.fee.to_i, 
            transfer_timestamp: transfer.timestamp,
          }
        else
          return {
            status:  "failed",
            message: "Transaction failed for some reason. The message returned was '#{res.message}'"
          }  
        end  
      end
    else
      return {
        status: "failed",
        message: "Insufficient XEM balance for transaction fees"
      }
    end
  end  

  def xem_and_gwx_balance(wallet_address)
    account = Nem::Endpoint::Account.new(@node)

    xem_mosaic = (account.mosaic_owned(wallet_address).attachments.select { |attachment| 
      attachment.mosaic_id.namespace_id == "nem" && attachment.mosaic_id.name == "xem"  
    }).first

    gameworks_namespace = Rails.env.production? ? "gameworks" : "gameworkss"
    
    gwx_mosaic = (account.mosaic_owned(wallet_address).attachments.select { |attachment| 
      attachment.mosaic_id.namespace_id == gameworks_namespace && attachment.mosaic_id.name == "gwx"
    }).first

    return {
      xem: xem_mosaic.nil? ? nil : xem_mosaic.quantity,
      gwx: gwx_mosaic.nil? ? nil : gwx_mosaic.quantity
    }
  end
  
  def xem_transfer(source_wallet_address, dest_wallet_address, source_wallet_pk, quantity)
    
    # get the current balance for xem and gwx
    mosaic_balance = xem_and_gwx_balance(source_wallet_address)
    xem_balance = mosaic_balance[:xem]
    
    # check if the wallet has the minimum amount of xem  
    if xem_balance > @params[:min_xem_balance]
      
      transaction = Nem::Endpoint::Transaction.new(@node)
      key_pair    = Nem::Keypair.new(source_wallet_pk)
    
      transfer = Nem::Transaction::Transfer.new(dest_wallet_address, quantity, nil, timestamp: Time.now - 1000)
    
      req = Nem::Request::Announce.new(transfer, key_pair)
      res = transaction.announce(req)
    
      # check if the transaction was successful
      if res.message.downcase == "success"
        return {
          status:             "success",
          message:            "Transaction successful.",
          transfered_amount:  quantity,
          transaction_hash:   res.transaction_hash,
          transfer_fee:       transfer.fee.to_i, 
          transfer_timestamp: transfer.timestamp,
        }
      else
        return {
          status:  "failed",
          message: "Transaction failed for some reason. The message returned was '#{res.message}'"
        }
      end   
    else
      return {
        status: "failed",
        message: "Insufficient XEM balance for transaction fees"
      }
    end      
  end  
  
  ##
  ##
  ##
=begin  
  def convert_mosaic_quantity_value(quantity)
    "#{quantity}".insert(-7, ".").to_f
  end
  
  def pretty_print_mosaic_value(value)
    "%.6f" % [value]
  end
  ##
  ##
  ## 
=end   
   
end