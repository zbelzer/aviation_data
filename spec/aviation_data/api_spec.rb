require 'spec_helper'

describe AviationData::Api do
  describe "GET /v1/aircraft/:identifier" do
    it "returns 404 for unfound aircraft" do
      get "/aircraft/search/N1234"

      response.status.should == 404
    end

    it "represents found aircraft" do
      aircraft = FactoryGirl.create(:aircraft)
      stub_wisper_publisher("AviationData::Aircrafts::FindAircraft", :run, :success, aircraft)
      
      get "/aircraft/search/N1234"

      response.status.should == 200
      result = JSON.parse(response.body)

      expect(result).to eq({
       "aircraft_category" => "land",
       "aircraft_type"     => "fixed_wing_single_engine",
       "engine_type"       => "Reciprocating",
       "identifier"        => "N1",
       "manufacturer_name" => "101 FLYING ASSOC INC",
       "model_name"        => " SEAREY",
       "weight"            => "CLASS 1"
      })
    end
  end

  describe "GET /v1/airport/:identifier" do
    it "returns 404 for unfound aircraft" do
      get "/airport/search/LAX"

      response.status.should == 404
    end

    it "represents found airport" do
      airport = FactoryGirl.create(:airport)
      stub_wisper_publisher("AviationData::Airports::FindAirport", :run, :success, airport)
      
      get "/airport/search/N1234"

      response.status.should == 200
      result = JSON.parse(response.body)

      expect(result).to eq({
        "iata" => "LAX",
        "icao" => "KLAX",
        "name" => "Los Angeles International"
      })
    end
  end
end
