require 'spec_helper'

describe Airman do
  it "creates a new Dealer record" do
    record = Airman.create
    expect(record).to be_persisted
  end
end
