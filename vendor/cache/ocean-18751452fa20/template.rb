
# Update the Gemfile
add_source 'http://rubygems.org'
gem "ocean", git: "git://github.com/OceanDev/ocean.git"

# Install a .rvmrc file
run "rvm rvmrc create ruby-2.0.0-p195@rails-3.2.13"
# Select the ruby and gem bag
run "rvm use ruby-2.0.0-p195@rails-3.2.13"
# Run bundle install - we need the generators in it now
run "bundle install"

# Set up the application as a SOA service Rails application
generate "ocean_setup", app_name

# Clean up the Gemfile
gsub_file "Gemfile", /gem 'rails'.+# gem 'debugger'\s+/m, ''
gsub_file "Gemfile", /group/, "\ngroup"

# Install the required gems and package them with the app
run "bundle install"
run "bundle package --all"

# Remove the asset stuff from the application conf file
gsub_file "config/application.rb", 
          /    # Enable the asset pipeline.+config\.assets\.version = '1\.0'\s/m, ''

# Set up SQLite to run tests in memory
gsub_file "config/database.yml",
          /test:\s+adapter: sqlite3\s+database: db\/test.sqlite3/m,
          'test:
  adapter: sqlite3
  database: ":memory:"
  verbosity: quiet'

rake "db:migrate"
