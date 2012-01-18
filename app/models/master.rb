class Master
  include MongoMapper::Document

  AIRCRAFT_HEADERS = %w(identifier serial_number aircraft_model_code engine_mode_code year_manufactured type_registrant registrant_name street1 street2 registrant_city registrant_state registrant_zip registrant_region county_mail country_mail last_activity_date certificate_issue_date approved_operation_codes type_aircraft type_engine status_code transponder_code fractional_ownership airworthiness_date owner_one owner_two owner_three owner_four owner_five)
  REFERENCE_HEADERS = %w(aircraft_model_code manufacturer model_name type_aircraft type_engine aircraft_category_code builder_certification_code engines seats weight cruising_speed)

  key :identifier, String, :index => true
  key :serial_number, String, :index => true
  key :aircraft_model_code, String, :index => true
  key :engine_mode_code, Integer
  key :year_manufactured, Integer
  key :type_registrant, Integer
  key :registrant_name, String
  key :street1, String
  key :street2, String
  key :registrant_city, String
  key :registrant_state, String
  key :registrant_zip, String # Could be 90503-5115
  key :registrant_region, Integer
  key :county_mail, String
  key :country_mail, String
  key :last_activity_date, Date
  key :certificate_issue_date, Date
  key :approved_operation_codes, String
  key :type_aircraft, Integer
  key :type_engine, Integer
  key :status_code, String
  key :transponder_code, Integer
  key :fractional_ownership, String
  key :airworthiness_date, Date
  key :owner_one, String
  key :owner_two, String
  key :owner_three, String
  key :owner_four, String
  key :owner_five, String
  key :import_date, Date, :index => true

  timestamps!

  def self.hash_from_csv_row(headers, row)
    values = row.split(',').map {|x| x.strip}
    Hash[*headers.zip(values).flatten(1)]
  end

  def self.import_date_from_name(name)
    Time.zone.local_to_utc(DateTime.strptime(name.gsub('AR', ''), '%m%Y'))
  end

  def self.import_aircraft_from_csv(folder_path)
    file_path = get_file_path(folder_path, "MASTER")
    import_date = import_date_from_name(File.basename(folder_path))
    # references = create_reference_map(folder_path)

    count = 0
    seen_header = false

    File.foreach(file_path) do |row|
      if !seen_header
        seen_header = true
        next
      end

      data = hash_from_csv_row(AIRCRAFT_HEADERS, row)
      # if reference_data = references[data["aircraft_model_code"]]
      #   data.merge!(reference_data)
      # else
      #   logger.warn "Skipped #{data["aircraft_model_code"]} for some reason"
      # end

      # data.merge!("identifier" => "N" + data["identifier"], "import_date" => import_date)
      # clean_data = clean(data)

      create(data)
      count += 1
    end

    count
  end

  def self.create_reference_map(folder_path)
    file_path = get_file_path(folder_path, "ACTREF")

    references = {}
    seen_header = false

    File.foreach(file_path) do |row|
      if !seen_header
        seen_header = true
        next
      end

      reference = hash_from_csv_row(REFERENCE_HEADERS, row)
      references[reference["aircraft_model_code"]] = reference
    end

    references
  end

  def self.get_file_path(folder_path, file_name)
    file_path = folder_path + "/#{file_name}"
    file_path + ".txt" unless File.exists?(file_path)
  end

  def self.compress_record(data)
    data.reject {|k, v| v.blank?}
  end
end
