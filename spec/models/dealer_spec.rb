require 'spec_helper'

describe Dealer do
  it "creates a new Dealer record" do
    dealer = Dealer.create
    expect(dealer).to be_persisted
  end
end
