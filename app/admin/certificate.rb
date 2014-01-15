ActiveAdmin.register Certificate do
  config.sort_order = "unique_number asc"

  filter :certificate_type, as: :select
  filter :certificate_level, as: :select

  index do
    column :airman
    column :certificate_type
    column :certificate_level
  end
end
