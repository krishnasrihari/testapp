Before do |scenario|
  DatabaseCleaner.start
  puts "databaseCleaner started #{scenario.name}"
end

After do |scenario|
  DatabaseCleaner.clean
  puts 'databaseCleaner cleaned the db'
  puts 'scenario failed' if scenario.failed?
end

Before('@admin') do
	puts 'admin tagged hook'
end

Around do |scenario,block|
	puts "About to run #{scenario.name}"
	block.call
	puts "Finshed the scenario: #{scenario.name}"
end

Around('@run_with_and_without_javascript') do |scenario, block|
	Capybara.current_driver = Capybara.javascript_driver
	block.call
	Capybara.use_default_driver
	block.call
end
