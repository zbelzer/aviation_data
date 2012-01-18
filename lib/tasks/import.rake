desc "Imports all data"
task :import do
  Rake::Task['faa:aircraft:import'].invoke
  Rake::Task['faa:airmen:import'].invoke
  Rake::Task['airports:import'].invoke
end
