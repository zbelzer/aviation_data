require 'spec_helper'

describe PilotBasic do
  it "creates a new PilotBasic record" do
    record = PilotBasic.create
    expect(record).to be_persisted
  end
end
