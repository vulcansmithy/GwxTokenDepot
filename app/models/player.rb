class Player
  include Mongoid::Document
  
  field :first_name, type: String, default: nil
  field :last_name,  type: String, default: nil
  field :email,      type: String, default: nil
end
