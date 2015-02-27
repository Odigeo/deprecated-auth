source "https://rubygems.org"

gem "rails", "4.2.1.rc2"
gem "ocean-rails"
gem "ocean-dynamo"

gem "pg"                 # PostgreSQL
gem "foreigner"          # Foreign key constraints in MySQL, PostgreSQL, and SQLite3.

gem 'oj'
gem 'oj_mimic_json'
gem "jbuilder"

gem "bcrypt"             # Password hashing, etc
gem 'email_validator'

group :test, :development do
  gem "sqlite3"            # Dev+testing+CI (staging and production use mySQL)
  gem 'memory_test_fix'    # Makes SQLite run in memory for speed
  gem "rspec-rails"
  gem "simplecov", :require => false
  gem "factory_girl_rails", "~> 4.0"
  gem "immigrant"
  gem "annotate", ">=2.5.0"
end

# Rails 3 compatibility
gem "protected_attributes"

gem "rack-attack"
gem "dalli"
