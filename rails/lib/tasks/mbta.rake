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

  desc "Update trips to contain direction, after older version of populate"
  task :add_directions => [:environment, 'db:migrate'] do
    Generator.generate('trips.txt') do |row|
      trip = Trip.find_by_mbta_id row[2]
      next unless trip
      trip.direction_id = row[4]
      trip.save
      puts "Added direction #{trip.direction_id} to trip #{trip.mbta_id}"
    end
  end

end
