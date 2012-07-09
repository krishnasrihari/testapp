Feature: Showtime Descriptions
	So that I can find movies that fit my schedule
	As a movie goer
	I want to see accurate and concise showtimes
	
	@wip
	Scenario: Show minutes for times not ending with 00
		Given a movie
		When I set the showtime to "2012-07-05" at "3:15pm"
		Then the showtime description should be "July 05, 2012 (3:15pm)"
		
	Scenario: Hide minutes for times ending with 00
		Given a movie
		When I set the showtime to "2012-07-05" at "3:00pm"
		Then the showtime description should be "July 05, 2012 (3pm)"