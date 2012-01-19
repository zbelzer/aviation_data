desc "Imports all data"
task :import do
  Rake::Task['aircraft:import'].invoke
  Rake::Task['airmen:import'].invoke
  Rake::Task['airports:import'].invoke
end
