class CreateBuilderCertifications < ActiveRecord::Migration
  def change
    create_enum :builder_certifications, :name_length => 50, :description => true
  end
end
