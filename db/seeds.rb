State.enumeration_model_updates_permitted = true
CSV.foreach(File.expand_path("../state_provinces.txt", __FILE__), :col_sep => ' ') do |row|
  State.create!(:name => row[0], :description => row[1])
end

IdentifierType.enumeration_model_updates_permitted = true
IdentifierType.create(:name => 'n_number')
IdentifierType.create(:name => 'transponder_code')

