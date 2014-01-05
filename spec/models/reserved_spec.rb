require 'spec_helper'

describe Reserved do
  it "creates a new Reserved record" do
    reserved = Reserved.create
    expect(reserved).to be_persisted
  end
end
