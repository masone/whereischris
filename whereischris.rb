require 'sinatra'
require 'net/http'
           
set :static, true
set :public_folder, "#{File.dirname(__FILE__)}/public"   
set :inline_templates, true

get '/' do
  url = 'https://p01-calendarws.icloud.com/ca/subscribe/1/qUBdyRB0mJAJZXWyriH5iJ0HAiNh6aPefh5ep8HrB4eA3h4XZl6NBybz75lK2KyAr-ZGNp0tEfUBXfJdy8KDEXzXxdAKIHI5IB_IB10Rbs4'   
  uri = URI.parse(url)
  response = HTTParty.get(url)
  
  if response.code == 200
    cals = Icalendar.parse(response.body)
    cal = cals.first
        
    @current_location = current_event(cal).summary
    @next_travel_date = next_event(cal).dtstart
    
    haml :index    
  else
    raise response.code
  end  
end  

private

def current_event(cal)
  sorted_events(cal).reverse.find do |event|
    event.dtstart <= DateTime.now
  end
end    

def next_event(cal)
  sorted_events(cal).find do |event|
    event.dtstart > DateTime.now
  end
end   

def sorted_events(cal)
  @sorted_events ||= cal.events.sort_by{|e| e.dtstart.to_s}
end 

__END__

@@ layout  
!!!
%html
  %head
    %meta{charset: "utf-8"}/
    %meta{content: "width=device-width, initial-scale=1.0", name: "viewport"}/
    %title Where is Chris?
    %link{rel: "stylesheet", href: "/styles.css"}
  %body
  = yield

@@index
.container
  %h1= @current_location
  %p.next= @next_travel_date.strftime("until %e.%-m.%Y")
