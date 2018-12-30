# Kimurai::Dashboard

Simple Dashboard for [Kimurai web scraping framework](https://github.com/vifreefly/kimuraframework). Required version of Kimurai `>= 1.3.0`.

## Installation
Add this line to your Kimurai project's Gemfile:

```ruby
# add this line after `gem 'kimurai'`
gem 'kimurai-dashboard', require: false
```

and then execute `$ bundle`.

## Configuration
You need to provide `stats_database_url` to enable stats and save info about project spiders runs and sessions to a database. Format for a database url: https://sequel.jeremyevans.net/rdoc/files/doc/opening_databases_rdoc.html. You can use _sqlite_, _postgres_ or _mysql_ database (check Kimurai's project Gemfile and uncomment preferred gem).

Example for SQlite:

```ruby
# Gemfile
gem 'sqlite3'
```

**Note that dashboard should be required only after stats_database_url provided:**

```ruby
# config/boot.rb
# ...

Kimurai.configuration.stats_database_url = "sqlite://db/spiders_runs_#{Kimurai.env}.sqlite3"
# Important: require dashboard ONLY after stats_database_url was provided:
require 'kimurai/dashboard'
```

Also, there are optional settings for a dashboard:

```ruby
# config/application.rb

Kimurai.configure do |config|
  # ...

  config.dashboard = {
    bind_address: "0.0.0.0",
    port: 3001,
    basic_auth: { username: "admin", password: "123456" }
  }
end
```

## Usage
After successful configuration, all spiders (running individually `kimurai start` or in queue `kimurai runner`) will save stats to the database.

Run `$ bundle exec kimurai dashboard` and navigate to a dashboard url to see the stats.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
