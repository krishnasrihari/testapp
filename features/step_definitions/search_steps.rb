When /^I search for "(.*?)"$/ do |query|
	visit('/search')
	fill_in 'searches_query', :with => query
	click_button 'search'
end

Then /^the results should be:$/ do |expected_result|
  # table is a Cucumber::Ast::Table  
	expected_result.hashes.each do |result|
  	assert(page.has_content?(result['content']))
  end
end

