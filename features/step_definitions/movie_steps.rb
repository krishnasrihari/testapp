Given /^a genre named Comedy$/ do
  @genre = FactoryGirl.create(:genre, name: 'Comedy')
end

When /^I create a movie Caddyshack in the Comedy genre$/ do
	visit('/movies')
	click_on('Add Movie')
	fill_in('movie[name]', with: 'Caddyshack')
	select('1980', from: 'movie[release]')
	check "genres_"
	click_button('Save')  
end

Then /^Caddyshack should be in the Comedy genre$/ do
  pending # express the regexp above with the code you wish you had
end