require 'spec_helper'

describe AviationData::Aircrafts::FindAircraft do
  let(:identifier) { "N1234" }
  let(:params) { { identifier: identifier } }
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
    it "finds an aircraft by identifier" do
      aircraft = Aircraft.create(:identifier => Identifier.new(:code => identifier))
      expect(finder.find_aircraft).to eq(aircraft)
    end

    it "finds an aircraft by identifier and date" do
      earlier_date = DateTime.new(2013, 3, 4)
      as_of_1      = DateTime.new(2013, 6, 6)
      later_date   = DateTime.new(2014, 2, 4)
      as_of_2      = DateTime.new(2014, 3, 1)

      common_identifier = Identifier.new(:code => identifier)
      earlier_aircraft = Aircraft.create!(identifier: common_identifier, as_of: earlier_date)
      later_aircraft = Aircraft.create!(identifier: common_identifier, as_of: later_date)

      finder = AviationData::Aircrafts::FindAircraft.new(params.merge(date: as_of_1))
      expect(finder.find_aircraft).to eq(earlier_aircraft)

      finder = AviationData::Aircrafts::FindAircraft.new(params.merge(date: as_of_2))
      expect(finder.find_aircraft).to eq(later_aircraft)
    end
  end
end
