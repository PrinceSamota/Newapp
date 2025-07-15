source "https://rubygems.org"

# Use the Puma web server
gem "puma", ">= 5.0"
gem "rails", "~> 7.2.2", ">= 7.2.2.1"
gem "sprockets-rails"
gem "jsbundling-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "cssbundling-rails"
gem "jbuilder"
gem 'devise'
gem 'cssbundling-rails'
gem 'roo'
gem 'bootsnap', require: false
gem 'paper_trail', '~> 13.0'

# PostgreSQL instead of SQLite
group :development, :test do
  gem "sqlite3", group: :production
  gem "pg", group: :production
end

group :development do
  gem "web-console"
  gem "error_highlight", ">= 0.4.0", platforms: [:ruby]
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end

group :production do
  gem 'pg'
end
