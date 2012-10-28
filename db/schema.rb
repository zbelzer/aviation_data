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

ActiveRecord::Schema.define(:version => 20121028000002) do


  create_table "aircraft_categories", :force => true do |t|
    t.string "name",        :null => false
    t.string "description"
  end

  add_index "aircraft_categories", ["name"], :name => "index_aircraft_categories_on_name", :unique => true

  create_table "aircraft_engine_types", :force => true do |t|
    t.string "name",        :null => false
    t.string "description"
  end

  add_index "aircraft_engine_types", ["name"], :name => "index_aircraft_engine_types_on_name", :unique => true

  create_table "aircraft_reference", :force => true do |t|
    t.string  "code"
    t.string  "manufacturer_name"
    t.string  "model_name"
    t.string  "aircraft_type"
    t.string  "engine_type"
    t.string  "aircraft_category_code"
    t.string  "builder_certification_code"
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
  end

  add_index "aircrafts", ["identifier_id", "model_id"], :name => "index_aircrafts_on_identifier_id_and_model_id", :unique => true
  add_index "aircrafts", ["identifier_id"], :name => "index_aircrafts_on_identifier_id"
  add_index "aircrafts", ["model_id"], :name => "index_aircrafts_on_model_id"

  create_table "cities", :force => true do |t|
    t.string "name", :null => false
  end

  add_index "cities", ["name"], :name => "index_cities_on_name", :unique => true

  create_table "identifier_types", :force => true do |t|
    t.string "name",        :null => false
    t.string "description"
  end

  add_index "identifier_types", ["name"], :name => "index_identifier_types_on_name", :unique => true

  create_table "identifiers", :force => true do |t|
    t.integer "identifier_type_id"
    t.string  "code"
    t.date    "started_at"
    t.date    "ended_at"
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
    t.string  "aircraft_category_code"
    t.string  "builder_certification_code"
    t.integer "engines"
    t.integer "seats"
    t.integer "weight_id"
    t.integer "cruising_speed"
  end

  add_index "models", ["aircraft_type_id"], :name => "index_models_on_aircraft_type_id"
  add_index "models", ["code"], :name => "index_models_on_code"
  add_index "models", ["manufacturer_name_id"], :name => "index_models_on_manufacturer_name_id"
  add_index "models", ["model_name_id"], :name => "index_models_on_model_name_id"

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

  add_foreign_key "models", "public.aircraft_types", :name => "models_aircraft_type_id_fk", :column => "aircraft_type_id", :exclude_index => true
  add_foreign_key "models", "public.manufacturer_names", :name => "models_manufacturer_name_id_fk", :column => "manufacturer_name_id", :exclude_index => true
  add_foreign_key "models", "public.model_names", :name => "models_model_name_id_fk", :column => "model_name_id", :exclude_index => true

end
