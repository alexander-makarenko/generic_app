source 'https://rubygems.org'

ruby '2.3.0'
#ruby-gemset=generic_app

gem 'rails'
gem 'pg'
gem 'bcrypt'
gem 'bootstrap-sass'
gem 'bootstrap_form'
gem 'haml-rails'
gem 'sass-rails'
gem 'faker'
gem 'uglifier'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder'
gem 'pundit', github: 'elabs/pundit'
gem 'rails-i18n'
gem 'paperclip', github: 'thoughtbot/paperclip', ref: '523bd46c768226893f23889079a7aa9c73b57d68'
gem 'jquery-fileupload-rails'
gem 'bootstrap-will_paginate'
gem 'bootstrap-datepicker-rails', require: 'bootstrap-datepicker-rails',
  github:'Nerian/bootstrap-datepicker-rails'

group :development, :test do  
  gem 'rspec-rails'
  gem 'jasmine-rails'
  gem 'guard-rspec'
  gem 'guard-jasmine'
  gem 'spring-commands-rspec'
  gem 'show_me_the_cookies'
end

group :test do
  gem 'capybara', github: 'jnicklas/capybara'
  gem 'capybara-webkit', github: 'thoughtbot/capybara-webkit'
  gem 'selenium-webdriver'
  gem 'libnotify'
  gem 'factory_girl_rails'
  gem 'launchy'
  gem 'timecop'
  gem 'database_cleaner', github: 'DatabaseCleaner/database_cleaner'
end

group :production do  
  gem 'rails_12factor'
  gem 'aws-sdk'
end