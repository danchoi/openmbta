namespace :mbta do

  desc "populate from data files"
  task :populate => :environment do
    [Route, Service, ServiceException, Trip, Stop, Stopping].each do |x|
      puts "Populating #{x.to_s}"
      x.populate
    end
    puts "\n\nDenormalizing trips..."
    Trip.denormalize
    Route.cache_short_name_on_trips
  end
end
