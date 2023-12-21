source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.0.3"

gem "rails", "~> 7.0.8"

gem "sprockets-rails"

gem "pg", "~> 1.1"
gem "puma", "~> 5.0"

gem "bootsnap", require: false
gem "cssbundling-rails"
gem 'dry-validation'
gem "jsbundling-rails"
gem "stimulus-rails"
gem "turbo-rails"
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

group :development, :test do
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem 'rspec-rails', '~> 6.0.0'
  gem 'pry-byebug'
end

group :development do
  gem "web-console"
end

