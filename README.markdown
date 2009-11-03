# OpenMBTA iPhone App

OpenMBTA is a free, open source iPhone application that gives users current
schedule information for MBTA buses, commuter rail lines, subway, and ferries. 
MBTA the public transit system of the Boston metropolitan area.

This project has two components: an XCode project for the iPhone app and a Rails
application for the data backend. The iPhone app relies on the backend to feed
it schedule data and stop coordinates to display on its maps and schedule tables. 

The backend, in turn, uses the MBTA's Google Transit Feed Specification data to
populate its database. The database must be reloaded with new GTFS schedule data
about once every 3 months to keep the schedule information current.

Note that this project is in an early stage. There is a lot of room for adding
features and improving the UI. 

## How to set up a development environment

Follow these instruction to set up a local version the Rails backend. The Rails
code is located in the `rails` directory of the project.  Set up the
`config/database.yml` file as usual to suit your development environment and
then run `rake db:migrate`.

Next, create a folder inside the `rails` directory named `data`. 

Now you need to get the MBTA GTFS data from the [EOT Developers
Page](http://www.eot.state.ma.us/developers/). Download the full MBTA GTFS zip
file containing all the services. This file is currently linked from the middle
of the page.

Unzip the file. You should see a bunch of *.csv files. Transfer these csv files
to the `rails/data` directory.

Now we're ready to populate the MySQL database with the GFTS data. There is a
rake task for this. Run 

    rake mbta:populate

Be warned that the GFTS dataset is huge, with over 3 million rows. On my
Macbook Pro this task takes more than 2 or 3 hours to finish.

After the `mbta:populate` task is finished, you should be able to start the
Rails app with `script/server`. 

Now we can to run a local copy of the OpenMBTA iPhone app as a client to the
local copy of the Rails data server.

Go to the `OpenMBTA` directory of the project, which contains the XCode project
for the iPhone app. Open the project in XCode, and then just Build and Run. The
development version of the iPhone code is set to use `http://localhost:3000` as
the URL of the data backend. If you want to run the iPhone client against some
other URL, change macro definition for `ServerURL` `Classes/ServerUrl.h`. 

## Figuring out your way around the code

The best way to dive in is to watch the development log of the Rails app while
you play around around with the iPhone client. By doing the this you'll see when
the iPhone app is making a request to the backend, what URL is being called, and
what SQL statements are being executed to generate the response. You won't be
able to see the response returned by the backend in the log, but you can get the
response by copying the request URL noted in the log and making the same request
with `curl` (or something similar) from the command line. When you do this, make
sure you append `:3000` to `localhost` as the Rails logger doesn't seem to
record the port number of incoming requests. The responses returned to the
iPhone all are all formatted in JSON.

From this point on, I would suggest looking at `config/routes.rb` to trace the
URL requests to the controllers that handle them. The controllers, in turn, point 
to the model classes that construct the appropriate SQL calls and assemble the
data for each response.

As for the iPhone end, if you have experience in Objective-C development for the
iPhone, you should be able to figure things out. If you have any questions, just
ask them in the [OpenMBTA Google
Group](http://groups.google.com/group/openmbta).

One thing to note about the iPhone client code is the `USE_DEMO_LOCATION` macro
definition at the top `Classes/TripsMapViewController.m`. Because the iPhone
Simulator always calculates the iPhone's location as Cupertino, California, I
had to fake a user location in Cambridge, MA to test some of the location-aware
features of OpenMBTA in the Simulator. `USE_DEMO_LOCATION` is set to 1 by by
default. This should be set to 0 whenever the app is built for deployment on an
actual iPhone or iPod touch device.

Currently, there are no unit or integration tests for this codebase. This is
definitely one area where volunteers can contribute. The first version of
OpenMBTA was written quickly and not with the best code hygiene.

## On collaborating and pushing out the next version

Join [OpenMBTA Google Group](http://groups.google.com/group/openmbta) to
communicate with everyone else who works on this project. Maybe we should also
set up a wiki somewhere, but that's something we can discuss in the Google Group.

Another we need to do is to set up a collective entity through which to publish
future versions of this application on the iTunes App Store and to set up a
project team in the iPhone Dev Center. 


## Open Source License

The source code for OpenMBTA is governed by the MIT License, which reads as
follows:

    Copyright (c) 2009 Daniel Choi

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to
    deal in the Software without restriction, including without limitation the
    rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
    sell copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
    IN THE SOFTWARE.

