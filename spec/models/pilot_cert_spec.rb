require 'spec_helper'

describe PilotCert do
  it "creates a new PilotCert record" do
    record = PilotCert.create
    expect(record).to be_persisted
  end
end
