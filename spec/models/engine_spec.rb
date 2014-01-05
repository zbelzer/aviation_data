require 'spec_helper'

describe Engine do
  it "creates a new Engine record" do
    engine = Engine.create
    expect(engine).to be_persisted
  end
end
