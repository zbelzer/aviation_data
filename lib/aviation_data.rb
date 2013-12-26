module AviationData
  DATA_DIR = Rails.root.join('db/data')
  AIRCRAFT_DIR = File.join(DATA_DIR, 'aircraft')
  AIRMEN_DIR = File.join(DATA_DIR, 'airmen')
  AIRPORT_PATH =  File.join(DATA_DIR, 'airports')

  DATABASE = "aviation_data_development"

  RATINGS = %w(rating1 rating2 rating3 rating4 rating5 rating6 rating7 rating8 rating9 rating10 rating11)
  HEADERS = {
    'MASTER'   => %w(identifier serial_number aircraft_model_code engine_mode_code year_manufactured type_registrant registrant_name street1 street2 registrant_city registrant_state registrant_zip registrant_region county_mail country_mail last_activity_date certificate_issue_date approved_operation_codes type_aircraft type_engine status_code transponder_code fractional_ownership airworthiness_date owner_one owner_two owner_three owner_four owner_five),
    'ACFTREF'  => %w(code manufacturer_name model_name aircraft_type_id engine_type_id aircraft_category_id builder_certification_id engines seats weight cruising_speed),
    # 'DEREG'    => %w(identifier serial_number aircraft_model_code status_code name address_1 address_2 city_mail state_abbrev_mail zip_code_mail engine_mode_code year_manufactured certification region county_mail country_mail airworthiness_date cancel_date mode_s_code indicator_group exp_country last_act_date cert_issue_date street_physical street2_physical city_physical state_abbrev_physical zip_code_physical county_physical country_physical owner_1 owner_2 owner_3 owner_4 owner_5),
    # 'DEALER'   => %w(certificate_number ownership certificate_date expiration_date expiration_flag certificate_issue_count name address_1 address_2 city state_abbrev zip_code other_names_count other_names_1 other_names_2 other_names_3 other_names_4 other_names_5 other_names_6 other_names_7 other_names_8 other_names_9 other_names_10 other_names_11 other_names_12 other_names_13 other_names_14 other_names_15 other_names_16 other_names_17 other_names_18 other_names_19 other_names_20 other_names_21 other_names_22 other_names_23 other_names_24 other_names_25),
    # 'ENGINE'   => %w(code manufacturer model type horsepower thrust),
    # 'RESERVED' => %w(identifier registrant address_1 address_2 city state zip code reserved_date tr expirtation_date identifier_change),
    # 'RELDOMCB' => %w(unique_number first_name last_name address_1 address_2 city state zip country region medical_class medical_date medical_expiration_date),
    # 'RELDOMCC' => %w(unique_number first_name last_name certificate_type level expiration_date) + RATINGS
  }

  AIRCRAFT_TABLE_MAP = [
    ['MASTER', 'master', 'Master'],
    ['ACFTREF', 'aircraft_reference', 'AircraftReference'],
    # ['DEREG', 'deregistered'],
    # ['DEALER', 'dealer'],
    # ['ENGINE', 'engine'],
    # ['RESERVED', 'reserved']
  ]

  AIRMEN_TABLE_MAP = [
    ['RELDOMCB', 'airmen'],
    ['RELDOMCC', 'certificates']
  ]

  require 'aviation_data/output_utilities'
  require 'aviation_data/conversion_utilities'

  require 'aviation_data/psql_import_utilities'
end
