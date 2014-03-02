require 'spec_helper'

describe AviationData::Airports::FindAirport do
  let(:identifier) { "N1234" }
  let(:params) { { identifier: identifier } }
  let(:finder) { AviationData::Airports::FindAirport.new(params) }

  describe "run" do
    let(:airport) { double('airport') }

    before { @called = false }
    after { expect(@called).to be_true }

    it "calls success with the airport if found" do
      finder.should_receive(:find_airport).and_return(airport)

      finder.on(:success) do |found_airport|
        expect(found_airport).to eq(airport)
        @called = true
      end

      finder.run
    end

    it "calls failure if no airport found" do
      finder.should_receive(:find_airport).and_return(nil)

      finder.on(:failure) do
        @called = true
      end

      finder.run
    end
  end

  describe "find_airport" do
    it "finds an airport by icao before iata" do
      icao_airport = Airport.create(:icao => identifier)
      iata_airport = Airport.create(:iata => identifier)

      expect(finder.find_airport).not_to eq(iata_airport)
      expect(finder.find_airport).to eq(icao_airport)
    end

    it "finds an airport by iata" do
      airport = Airport.create(:iata => identifier)
      expect(finder.find_airport).to eq(airport)
    end
  end
end
