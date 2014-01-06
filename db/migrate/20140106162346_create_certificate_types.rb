class CreateCertificateTypes < ActiveRecord::Migration
  def change
    create_enum :certificate_types, :name_length => 50, :description => true do |t|
      t.string :abbreviation
    end
  end
end
