# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140105205851) do


  create_table "aircraft_categories", :force => true do |t|
    t.string "name",        :null => false
    t.string "description"
  end

  add_index "aircraft_categories", ["name"], :name => "index_aircraft_categories_on_name", :unique => true

  create_table "aircraft_reference", :force => true do |t|
    t.string  "code"
    t.string  "manufacturer_name"
    t.string  "model_name"
    t.integer "aircraft_type_id"
    t.integer "engine_type_id"
    t.integer "aircraft_category_id"
    t.integer "builder_certification_id"
    t.integer "engines"
    t.integer "seats"
    t.string  "weight"
    t.integer "cruising_speed"
  end

  create_table "aircraft_types", :force => true do |t|
    t.string "name",        :null => false
    t.string "description"
  end

  add_index "aircraft_types", ["name"], :name => "index_aircraft_types_on_name", :unique => true

  create_table "aircrafts", :force => true do |t|
    t.integer "identifier_id"
    t.integer "model_id"
    t.integer "year_manufactured"
    t.integer "transponder_code"
    t.date    "as_of"
  end

  add_index "aircrafts", ["identifier_id", "model_id"], :name => "index_aircrafts_on_identifier_id_and_model_id", :unique => true
  add_index "aircrafts", ["identifier_id"], :name => "index_aircrafts_on_identifier_id"
  add_index "aircrafts", ["model_id"], :name => "index_aircrafts_on_model_id"

  create_table "builder_certifications", :force => true do |t|
    t.string "name",        :null => false
    t.string "description"
  end

  add_index "builder_certifications", ["name"], :name => "index_builder_certifications_on_name", :unique => true

  create_table "cities", :force => true do |t|
    t.string "name", :null => false
  end

  add_index "cities", ["name"], :name => "index_cities_on_name", :unique => true

  create_table "countries", :force => true do |t|
    t.string "name",        :null => false
    t.string "description"
  end

  add_index "countries", ["name"], :name => "index_countries_on_name", :unique => true

  create_table "dealers", :force => true do |t|
    t.string "certificate_number"
    t.string "ownership"
    t.string "certificate_date"
    t.string "expiration_date"
    t.string "expiration_flag"
    t.string "certificate_issue_count"
    t.string "name"
    t.string "address_1"
    t.string "address_2"
    t.string "city"
    t.string "state_abbrev"
    t.string "zip_code"
    t.string "other_names_count"
    t.string "other_names_1"
    t.string "other_names_2"
    t.string "other_names_3"
    t.string "other_names_4"
    t.string "other_names_5"
    t.string "other_names_6"
    t.string "other_names_7"
    t.string "other_names_8"
    t.string "other_names_9"
    t.string "other_names_10"
    t.string "other_names_11"
    t.string "other_names_12"
    t.string "other_names_13"
    t.string "other_names_14"
    t.string "other_names_15"
    t.string "other_names_16"
    t.string "other_names_17"
    t.string "other_names_18"
    t.string "other_names_19"
    t.string "other_names_20"
    t.string "other_names_21"
    t.string "other_names_22"
    t.string "other_names_23"
    t.string "other_names_24"
    t.string "other_names_25"
  end

  create_table "deregistered", :force => true do |t|
    t.string  "identifier"
    t.string  "serial_number"
    t.string  "aircraft_model_code"
    t.string  "status_code"
    t.string  "name"
    t.string  "address_1"
    t.string  "address_2"
    t.string  "city_mail"
    t.string  "state_abbrev_mail"
    t.string  "zip_code_mail"
    t.integer "engine_mode_code"
    t.integer "year_manufactured"
    t.string  "certification"
    t.string  "region"
    t.string  "county_mail"
    t.string  "country_mail"
    t.date    "airworthiness_date"
    t.date    "cancel_date"
    t.string  "mode_s_code"
    t.string  "indicator_group"
    t.string  "exp_country"
    t.date    "last_act_date"
    t.date    "cert_issue_date"
    t.string  "street_physical"
    t.string  "street2_physical"
    t.string  "city_physical"
    t.string  "state_abbrev_physical"
    t.string  "zip_code_physical"
    t.string  "county_physical"
    t.string  "country_physical"
    t.string  "owner_1"
    t.string  "owner_2"
    t.string  "owner_3"
    t.string  "owner_4"
    t.string  "owner_5"
  end

  create_table "engine_types", :force => true do |t|
    t.string "name",        :null => false
    t.string "description"
  end

  add_index "engine_types", ["name"], :name => "index_engine_types_on_name", :unique => true

  create_table "engines", :force => true do |t|
    t.string "code"
    t.string "manufacturer"
    t.string "model"
    t.string "type"
    t.string "horsepower"
    t.string "thrust"
  end

  create_table "identifier_types", :force => true do |t|
    t.string "name",        :null => false
    t.string "description"
  end

  add_index "identifier_types", ["name"], :name => "index_identifier_types_on_name", :unique => true

  create_table "identifiers", :force => true do |t|
    t.integer "identifier_type_id"
    t.string  "code"
  end

  add_index "identifiers", ["code"], :name => "index_identifiers_on_code", :unique => true
  add_index "identifiers", ["identifier_type_id"], :name => "index_identifiers_on_identifier_type_id"

  create_table "manufacturer_names", :force => true do |t|
    t.string "name", :null => false
  end

  add_index "manufacturer_names", ["name"], :name => "index_manufacturer_names_on_name", :unique => true

  create_table "master", :force => true do |t|
    t.string  "identifier"
    t.string  "serial_number"
    t.string  "aircraft_model_code"
    t.integer "engine_mode_code"
    t.integer "year_manufactured"
    t.integer "type_registrant"
    t.string  "registrant_name"
    t.string  "street1"
    t.string  "street2"
    t.string  "registrant_city"
    t.string  "registrant_state"
    t.string  "registrant_zip"
    t.string  "registrant_region"
    t.string  "county_mail"
    t.string  "country_mail"
    t.date    "last_activity_date"
    t.date    "certificate_issue_date"
    t.string  "approved_operation_codes"
    t.integer "type_aircraft"
    t.integer "type_engine"
    t.string  "status_code"
    t.integer "transponder_code"
    t.string  "fractional_ownership"
    t.date    "airworthiness_date"
    t.string  "owner_one"
    t.string  "owner_two"
    t.string  "owner_three"
    t.string  "owner_four"
    t.string  "owner_five"
    t.date    "expiration_date"
    t.integer "unique_id"
    t.string  "kit_manufacturer"
    t.string  "kit_model"
    t.string  "mode_s_code_hex"
  end

  add_index "master", ["aircraft_model_code"], :name => "index_master_on_aircraft_model_code"
  add_index "master", ["identifier"], :name => "index_master_on_identifier"
  add_index "master", ["serial_number"], :name => "index_master_on_serial_number"

  create_table "model_names", :force => true do |t|
    t.string "name",        :null => false
    t.string "description"
  end

  add_index "model_names", ["name"], :name => "index_model_names_on_name", :unique => true

  create_table "models", :force => true do |t|
    t.string  "code"
    t.integer "manufacturer_name_id"
    t.integer "model_name_id"
    t.integer "aircraft_type_id"
    t.integer "engine_type_id"
    t.integer "aircraft_category_id"
    t.integer "builder_certification_id"
    t.integer "engines"
    t.integer "seats"
    t.integer "weight_id"
    t.integer "cruising_speed"
  end

  add_index "models", ["aircraft_category_id"], :name => "index_models_on_aircraft_category_id"
  add_index "models", ["aircraft_type_id"], :name => "index_models_on_aircraft_type_id"
  add_index "models", ["builder_certification_id"], :name => "index_models_on_builder_certification_id"
  add_index "models", ["code"], :name => "index_models_on_code"
  add_index "models", ["engine_type_id"], :name => "index_models_on_engine_type_id"
  add_index "models", ["manufacturer_name_id"], :name => "index_models_on_manufacturer_name_id"
  add_index "models", ["model_name_id"], :name => "index_models_on_model_name_id"

  create_table "reserved", :force => true do |t|
    t.string "identifier"
    t.string "registrant"
    t.string "address_1"
    t.string "address_2"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.string "code"
    t.string "reserved_date"
    t.string "tr"
    t.string "expirtation_date"
    t.string "identifier_change"
  end

  create_table "states", :force => true do |t|
    t.string "name",        :null => false
    t.string "description"
  end

  add_index "states", ["name"], :name => "index_states_on_name", :unique => true

  create_table "weights", :force => true do |t|
    t.string "name",        :null => false
    t.string "description"
  end

  add_index "weights", ["name"], :name => "index_weights_on_name", :unique => true

  add_foreign_key "aircrafts", "public.identifiers", :name => "aircrafts_identifier_id_fk", :column => "identifier_id", :exclude_index => true
  add_foreign_key "aircrafts", "public.models", :name => "aircrafts_model_id_fk", :column => "model_id", :exclude_index => true

  add_foreign_key "identifiers", "public.identifier_types", :name => "identifiers_identifier_type_id_fk", :column => "identifier_type_id", :exclude_index => true

  add_foreign_key "models", "public.aircraft_categories", :name => "models_aircraft_category_id_fk", :column => "aircraft_category_id", :exclude_index => true
  add_foreign_key "models", "public.aircraft_types", :name => "models_aircraft_type_id_fk", :column => "aircraft_type_id", :exclude_index => true
  add_foreign_key "models", "public.builder_certifications", :name => "models_builder_certification_id_fk", :column => "builder_certification_id", :exclude_index => true
  add_foreign_key "models", "public.engine_types", :name => "models_engine_type_id_fk", :column => "engine_type_id", :exclude_index => true
  add_foreign_key "models", "public.manufacturer_names", :name => "models_manufacturer_name_id_fk", :column => "manufacturer_name_id", :exclude_index => true
  add_foreign_key "models", "public.model_names", :name => "models_model_name_id_fk", :column => "model_name_id", :exclude_index => true

end
