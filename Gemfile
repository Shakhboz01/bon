source "http://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }
20.times do
  Buyer.create!(
    name: Faker::Name.name,
    phone_number: Faker::PhoneNumber.cell_phone_in_e164,
    comment: Faker::Lorem.sentence,
    active: [true, false].sample,
    weight: rand(0..100),
    latitude: Faker::Address.latitude,
    longitude: Faker::Address.longitude,
    agent_user_id: User.where(role: 'агент').pluck(:id).sample || User.first.id,
    diller_user_id: User.where(role: 'дилер').pluck(:id).sample || User.first.id,
    address: Faker::Address.full_address,
    debt_in_uzs: rand(0..1000).to_s,
    debt_in_usd: rand(0..1000).to_s,
  )
end

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.4", ">= 7.0.4.3"
gem 'geocoder'
gem 'faker'
gem 'kaminari', '~> 1.2'
gem "ransack"
gem "byebug"
gem 'jquery-rails'
gem 'jquery-ui-rails'
gem 'bootstrap-sass'
gem 'devise'
gem 'pundit'
gem 'simple_form'
gem "bulma-rails", "~> 0.9.4"
gem 'active_link_to'
gem "image_processing", ">= 1.2"
gem 'receipts'
gem 'chartkick'

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false
gem 'active_interaction'
gem 'telegram-bot-ruby'
gem 'figaro'
gem 'whenever'
gem 'font-awesome-rails'
gem 'google-cloud-storage', require: false

# Use Sass to process CSS
gem "sassc-rails"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
end
