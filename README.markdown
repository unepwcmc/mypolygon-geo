Sinatra app.

# Usage

ruby -rubygems marine_search_api.rb

# To populate a test db

Create empty db 'coral_distribution_2', owned by 'postgres'.
Do not add PostGIS functionality to it, the script will take care of that.

Execute this command: 'psql -d coral_distribution_2 -f coral_db -q'

This database has some test areas in the Samoa Islands region.

