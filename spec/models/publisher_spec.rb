require "rails_helper"

RSpec.describe Publisher, type: :model do
  it "should do something" do
    publisher = create(:publisher)
    expect(publisher.nil?).to eq false
  end
end
