source "https://rubygems.org"

gem "rails", "~> 4.0"
gem "ocean-rails", ">= 2.10.1"

gem "pg"                 # PostgreSQL
gem "foreigner"          # Foreign key constraints in MySQL, PostgreSQL, and SQLite3.

gem "jbuilder"           # We use Jbuilder to render our JSON responses
gem 'rails-patch-json-encode'  # Required for Rails 4.0.x
gem 'oj'

gem "bcrypt"             # Password hashing, etc


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
