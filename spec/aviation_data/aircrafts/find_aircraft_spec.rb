require 'spec_helper'

describe AviationData::Aircrafts::FindAircraft do
  let(:identifier) { "N1234" }
  let(:date) { DateTime.new(2013, 3, 4) }
  let(:params) { { identifier: identifier, date: date } }
  let(:finder) { AviationData::Aircrafts::FindAircraft.new(params) }

  describe "run" do
    let(:aircraft) { double('aircraft') }

    before { @called = false }
    after { expect(@called).to be_true }

    it "calls success with the aircraft if found" do
      finder.should_receive(:find_aircraft).and_return(aircraft)

      finder.on(:success) do |found_aircraft|
        expect(found_aircraft).to eq(aircraft)
        @called = true
      end

      finder.run
    end

    it "calls failure if no aircraft found" do
      finder.should_receive(:find_aircraft).and_return(nil)

      finder.on(:failure) do
        @called = true
      end

      finder.run
    end
  end

  describe "find_aircraft" do
    let(:identifier_model) { Identifier.new(:code => "1234") }

    it "finds existing aircraft with date on as_of date" do
      FactoryGirl.create(:aircraft, identifier: identifier_model, as_of: date + 10) # Decoy
      aircraft = FactoryGirl.create(:aircraft, identifier: identifier_model, as_of: date)

      finder = AviationData::Aircrafts::FindAircraft.new(identifier: identifier, date: date)
      expect(finder.find_aircraft).to eq(aircraft)
    end

    it "doesn't find existing aircraft with date before as_of date" do
      FactoryGirl.create(:aircraft, identifier: identifier_model, as_of: date + 10) # Decoy
      FactoryGirl.create(:aircraft, identifier: identifier_model, as_of: date)

      finder = AviationData::Aircrafts::FindAircraft.new(identifier: identifier, date: date - 5)
      expect(finder.find_aircraft).to be_nil
    end

    it "finds existing aircraft with date after as_of date but before next entry" do
      FactoryGirl.create(:aircraft, identifier: identifier_model, as_of: date + 10)
      earlier_aircraft = FactoryGirl.create(:aircraft, identifier: identifier_model, as_of: date)

      finder = AviationData::Aircrafts::FindAircraft.new(identifier: identifier, date: date + 5)
      expect(finder.find_aircraft).to eq(earlier_aircraft)
    end

    it "finds existing aircraft belonging to latest entry" do
      later_aircraft = FactoryGirl.create(:aircraft, identifier: identifier_model, as_of: date + 10)
      FactoryGirl.create(:aircraft, identifier: identifier_model, as_of: date)

      finder = AviationData::Aircrafts::FindAircraft.new(identifier: identifier, date: date + 15)
      expect(finder.find_aircraft).to eq(later_aircraft)
    end
  end
end
