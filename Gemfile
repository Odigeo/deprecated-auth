source "http://rubygems.org"

gem "rails", "4.0.0"
gem "ocean", git: "git://github.com/OceanDev/ocean.git"

gem "mysql2"
gem "foreigner"          # Foreign key constraints in MySQL, PostgreSQL, and SQLite3.

gem "jbuilder"           # We use Jbuilder to render our JSON responses

gem "bcrypt-ruby", :require => "bcrypt"       # Password hashing, etc


group :test, :development do
  gem "sqlite3"            # Dev+testing+CI (staging and production use mySQL)
  gem 'memory_test_fix'    # Makes SQLite run in memory for speed
  gem "rspec-rails", "~> 2.0"
  gem "simplecov", :require => false
  gem "factory_girl_rails", "~> 4.0"
  gem "immigrant"
  gem "annotate", ">=2.5.0"
end
# Rails 3 compatibility
gem "protected_attributes"
