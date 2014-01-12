class CreateCertificatesRatings < ActiveRecord::Migration
  def change
    create_table :certificates_ratings do |t|
      t.integer :certificate_id
      t.integer :certificate_rating_id
    end

    add_foreign_key :certificates_ratings, :certificates
    add_foreign_key :certificates_ratings, :certificate_ratings
  end
end
