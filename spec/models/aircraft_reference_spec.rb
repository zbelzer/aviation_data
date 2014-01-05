require 'spec_helper'

describe Reserved do
  it "creates a new AircraftReference record" do
    aircraft_reference = AircraftReference.create
    expect(aircraft_reference).to be_persisted
  end
end
