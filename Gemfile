# frozen_string_literal: true

source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

gemspec

group :development do
  gem "rake"
  gem "rubocop"
  gem "sqlite3"
  gem "warning"
  gem "yard"
end

group :test do
  gem "simplecov", require: false
end

group :development, :test do
  gem "pry"
end
