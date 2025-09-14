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
gem 'roo'
gem 'bootsnap', require: false
gem 'paper_trail', '~> 16.0'
gem 'will_paginate', '~> 4.0'
gem 'ransack'
gem "pg"
gem 'dotenv-rails'
gem 'axlsx_rails'
gem 'wicked_pdf'

# PostgreSQL instead of SQLite
group :development, :test do
  gem "sqlite3"
  gem "byebug"
end

group :development do
  gem "web-console"
  gem "error_highlight", ">= 0.4.0", platforms: [:ruby]
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end