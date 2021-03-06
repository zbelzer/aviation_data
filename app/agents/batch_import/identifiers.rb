# Utilities for importing data from Master to Identifiers.
module BatchImport::Identifiers
  # Create only new Identifiers from current Master information.
  #
  # @param [Package] package
  def self.import_latest(package)
    BatchImport::Runner.run(Master.missing_identifiers) do |batch_scope|

      identifiers = batch_scope.each_with_object([]) do |record, memo|
        memo << Identifier.new(
          :identifier_type_id => IdentifierType[:n_number],
          :code               => record.identifier
        )
      end

      Identifier.import(identifiers, :validate => false)
    end
  end
end
