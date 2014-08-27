require 'sinatra'
require 'net/http'

get '/' do
  url = 'https://p01-calendarws.icloud.com/ca/subscribe/1/qUBdyRB0mJAJZXWyriH5iJ0HAiNh6aPefh5ep8HrB4eA3h4XZl6NBybz75lK2KyAr-ZGNp0tEfUBXfJdy8KDEXzXxdAKIHI5IB_IB10Rbs4'   
  uri = URI.parse(url)
  response = HTTParty.get(url)
  if response.code == 200
    cals = Icalendar.parse(response.body)
    cal = cals.first

    current_event = cal.events.sort_by{|e| e.dtstart.to_s}.reverse.find do |event|
      event.dtstart <= DateTime.now
    end
           
    "<h1>#{current_event.summary.to_s}</h1>" 
  else
    raise response.code
  end
end
