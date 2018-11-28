require "rails_helper"

RSpec.describe User, type: :model do

  it "should do something" do
    user = create(:user)
    expect(user.nil?).to eq false
  end

end
