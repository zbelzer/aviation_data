namespace :faa do
  namespace :airmen do
    desc "Imports the releasable airmen and certificate databases"
    task :import => :environment do
      airmen_import_path = File.join(AIRMEN_DIR, "RELDOMCB")
      certificate_import_path = File.join(AIRMEN_DIR, "RELDOMCC")

      Airman.import(airmen_import_path)
      Certificate.import(certificate_import_path)
    end
  end
end
