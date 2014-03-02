ActiveAdmin.register Airman do
  config.sort_order = "last_name_asc"

  filter :unique_number, as: :string
  filter :first_name, as: :string
  filter :last_name, as: :string

  filter :medical_date, as: :date_range
  filter :medical_expiration_date, as: :date_range
  index do
    column :unique_number
    column :full_name
    column :medical_class
    column :medical_date
    column :medical_expiration_date

    column "Certificates" do |airman|
      certificates = airman.certificates

      if certificates.size > 0
        links = certificates.map do |c|
          link_to(c.certificate_type, admin_certificate_path(c))
        end

        links.join(', ').html_safe
      end
    end
  end
end
