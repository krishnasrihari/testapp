class Movie < ActiveRecord::Base
  attr_accessible :showtime_date, :showtime_time
  
  def showtime
  	"#{formated_date} (#{formated_time})"
  end
  
  def formated_date
  	showtime_date.strftime("%B %d, %Y")
  end
  
  def formated_time
  	formate_time = showtime_time.min.zero? ? "%l%p" : "%l:%M%p"
  	showtime_time.strftime(formate_time).strip.downcase
  end
  
end
