class CreateCertificateRating < ActiveRecord::Migration
  def change
    create_enum :certificate_rating, :description => true
  end
end
