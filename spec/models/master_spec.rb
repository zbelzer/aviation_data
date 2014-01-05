require 'spec_helper'

describe Master do
  it "creates a new Master record" do
    master = Master.create
    expect(master).to be_persisted
  end
end
