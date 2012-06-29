require 'capybara-webkit'
Capybara.javascript_driver = (ENV['JS'] || :webkit).to_sym
