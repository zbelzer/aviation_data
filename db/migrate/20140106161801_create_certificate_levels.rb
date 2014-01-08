class CreateCertificateLevels < ActiveRecord::Migration
  def change
    create_enum :certificate_levels, :name_length => 50, :description => true
  end
end
