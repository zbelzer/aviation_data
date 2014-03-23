# Central API nexus for the Aviation Data application.
class AviationData::Api < Grape::API
  version 'v1', using: :header, vendor: 'copilot'
  format :json

  resource :aircraft do
    desc "Search for an Aircraft by identifier"
    params do
      requires :identifier, type: String, desc: "Identifier"
    end

    get 'search/:identifier' do
      finder = AviationData::Aircrafts::FindAircraft.new(params)

      finder.on(:success) do |aircraft|
        header["Expires"] = Time.now.end_of_month.rfc2822
        return AircraftRepresenter.new(aircraft)
      end

      finder.on(:failure) do
        error! 'Not Found', 404
      end

      finder.run
    end
  end

  resource :airport do
    desc "Search for an Airport by identifier"
    params do
      requires :identifier, type: String, desc: "Identifier"
    end

    get 'search/:identifier' do
      finder = AviationData::Airports::FindAirport.new(params)

      finder.on(:success) do |airport|
        header["Expires"] = Time.now.end_of_month.rfc2822
        return AirportRepresenter.new(airport)
      end

      finder.on(:failure) do
        error! 'Not Found', 404
      end

      finder.run
    end
  end
end
