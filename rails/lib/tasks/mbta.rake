namespace :mbta do

  desc "populate from data files"
  task :populate => [:environment, 'db:migrate'] do
    [Route, Service, ServiceException, Trip, Stop, Stopping].each do |x|
      puts "Populating #{x.to_s}"
      x.populate
    end
    puts "\n\nDenormalizing trips..."
    Trip.denormalize
    #Route.cache_short_name_on_trips
    puts "\n\nFixing short names for silver line buses"
    Bus.populate_silver_lines
  end

  desc "denormalization only"
  task :denorm  => [:environment] do
    puts "\n\nDenormalizing trips..."
    Trip.denormalize
  end


end
