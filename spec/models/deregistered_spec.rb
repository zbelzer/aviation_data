require 'spec_helper'

describe Deregistered do
  it "creates a new Deregistered record" do
    deregistered = Deregistered.create
    expect(deregistered).to be_persisted
  end
end
