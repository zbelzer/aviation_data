# Utilities for importing data from PilotBasic to Airman.
module BatchImport::Certificates
  extend BatchImport::Helpers

  # Create only new Certificates from current PilotCert information.
  #
  # @param [Package] package
  def self.import_latest(package)
    BatchImport::Runner.run(PilotCert.missing_certifications) do |batch_scope|

      certificates = batch_scope.each_with_object([]) do |record, memo|
        certificate = Certificate.new(
          :airman_id           => record.airman_id,
          :certificate_type_id => record.certificate_type_id,
          :level               => record.level,
          :import_date         => package.import_date
        )

        set_date(record, certificate, :expiration_date)

        memo << certificate
      end

      Certificate.import(certificates, :validate => false)
    end
  end

end
