
class Concert_Search
	attr_reader :events, :songkick, :grooveshark


	def initialize(city, min_date, max_date)
		self.songkick = Songkick.new
		self.grooveshark =  Grooveshark.new
		@metro_calendar = Songkick.get_events_by_city_and_dates(city, min_date, max_date)
		events = []
		metro_calendar.each do |songkick_event|
			event = Event.new
			event.title = songkick_event['displayName'] 
			songkick_event['performance'].each do |performance|
				event.artists.push(performance['artist']['displayName'])
				top_song = Grooveshark.get_top_song(performance['artist']['displayName']) 
				unless top_song.empty?
					event.top_songs.push(top_song)
				end 
			end
			events.push(events)
		end 
	end

end 

class Event
	attr_accessor :title, :artists, :top_songs
	def initialize
		self.artists = []
		self.top_songs = []
	end
end 
