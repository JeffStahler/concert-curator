get '/' do 
	erb :index
end 


post '/search' do
 # @metro_calendar = Songkick.get_events_by_city_and_dates(params[:city], params[:min_date], params[:max_date])
  @calendar = Concert_Search.new  params[:city], params[:min_date], params[:max_date]
  erb :search
end

#post '/songkick' do 
##  erb :songk

post '/grooveshark' do 
  @song = Grooveshark.get_top_song(params[:query])
  @widget = Grooveshark.single_song_widget(@song['SongID']) if @song
  erb :grooveshark
end


post '/stream_spot' do
 
 @calendar = Venue_Search.new params[:query] 
 spotify_URIs_array = []
  stream do |out|
  	 out << "<ul>"
   	 @calendar.events.each do |event|		
		 out << "<li>"
		 out <<	event.title  	   	
	   	 out << "</li>"
		 out << "<ul>"
	   	 event.artists.each do |artist| 
	 		out << "<li>"
	 		out << artist
	 		out << "</li>"

	 		spotify_uri = Spotify.find_track(artist)
			unless spotify_uri.nil?
				spotify_URIs_array.push(spotify_uri)
			end 

     	 end
     	 out << "</ul>"
  	 end
  	 out << "</ul>"
  	 top_songs_spotify_uri = spotify_URIs_array.join('          ')
  	 out << top_songs_spotify_uri
  end

end


post '/venues' do
	
	@calendar = Venue_Search.new params[:query] 
	
	erb :venues
end

get '/multisong' do
	top_songs = []
	@ms = Grooveshark.mutli_song_widget(top_songs)
	erb :multi_song
end

get '/spotify' do 
	@search = Spotify.find_track('Beck')
	erb :spotify
end 



class Venue_Search
	attr_accessor :events, :top_songs, :playlist_widget, :top_songs_spotify_uri
    def initialize(query)
		gs = false 
		metro_calendar = Songkick.get_venue_events(query)
		self.events = []
		self.top_songs = []
		#spotify_URIs_array = []  
		metro_calendar.each do |songkick_event|
			event = Event.new
			event.title = songkick_event['displayName'] 
			songkick_event['performance'].each do |performance|
				artist_name = performance['artist']['displayName']
				event.artists.push(artist_name)
				#spotify_uri = Spotify.find_track(artist_name)
				#unless spotify_uri.nil?
			#		spotify_URIs_array.push(spotify_uri)
			#	end 

		#		if gs then  
	 	#     	 	top_song =   Grooveshark.get_top_song(artist_name)
	#				unless top_song.nil?					
#					self.top_songs.push(top_song['SongID'])							
		#			self.
		#			song_widget = Grooveshark.single_song_widget(top_song)
		#			event.top_songs[artist_name] = song_widget
					#event.artists.push(song_widget)
				
		#			end 
		#		end 
			end
			self.events.push(event)
			#self.top_songs_spotify_uri = spotify_URIs_array.join('          ')
			
		end 
		#if gs then 
		#	self.playlist_widget = Grooveshark.mutli_song_widget(self.top_songs)	
		#end 
	end

end 

class Concert_Search
	attr_accessor :events


	def initialize(city, min_date, max_date)
		metro_calendar = Songkick.get_events_by_city_and_dates(city, min_date, max_date)
		self.events = []
		metro_calendar.first(2).each do |songkick_event|
			event = Event.new
			event.title = songkick_event['displayName'] 
			songkick_event['performance'].each do |performance|
				artist_name = performance['artist']['displayName']
				event.artists.push(artist_name)
 	     	 	top_song =   Grooveshark.get_top_song(artist_name)
				if top_song.nil?					
					event.top_songs[artist_name] = 'No Song' 
	 			
				else
					song_widget = Grooveshark.single_song_widget(top_song)
					event.top_songs[artist_name] = song_widget
					#event.artists.push(song_widget)
				
				end 
			end
			self.events.push(event)
		end 
	end

end

class Event
	attr_accessor :title, :artists, :top_songs
	def initialize
		self.artists = []
		self.top_songs = {}
	end
end 








class Grooveshark
	ROOT_URL = 'http://tinysong.com/b/'
	FORMAT = '?format=json'
	API_PARAM = 'key=69cd853e5352c9d96db26925c3c770f6'

	# get top song
	# returns hash with 
	#   song['SongID']
	#   song['ArtistName']
	#   song['SongName']
	#   song['AlbumName']

	#... if found
	
	# returns nil if nothing found

	def self.get_top_song(query)

		query = URI.escape(query)		 
		url = "#{ROOT_URL}#{query}&#{FORMAT}&#{API_PARAM}"
		json = JSON.parse(RestClient.get(url))
		json.empty? ? nil : json 
	end


	def self.mutli_song_widget(song_ids)

		id = song_ids.join('')
		id_csv = song_ids.join(',')
		widget_html = '<object width="250" height="250" classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" id="gsManySongs_id_" name="gsManySongs_id_"><param name="movie" value="http://grooveshark.com/widget.swf" /><param name="wmode" value="window" /><param name="allowScriptAccess" value="always" /><param name="flashvars" value="hostname=cowbell.grooveshark.com&songIDs=_id_csv_&bbg=000000&bth=000000&pfg=000000&lfg=000000&bt=FFFFFF&pbg=FFFFFF&pfgh=FFFFFF&si=FFFFFF&lbg=FFFFFF&lfgh=FFFFFF&sb=FFFFFF&bfg=666666&pbgh=666666&lbgh=666666&sbh=666666&p=0" /><object type="application/x-shockwave-flash" data="http://grooveshark.com/widget.swf" width="250" height="250"><param name="wmode" value="window" /><param name="allowScriptAccess" value="always" /><param name="flashvars" value="hostname=cowbell.grooveshark.com&songIDs=_id_csv_&bbg=000000&bth=000000&pfg=000000&lfg=000000&bt=FFFFFF&pbg=FFFFFF&pfgh=FFFFFF&si=FFFFFF&lbg=FFFFFF&lfgh=FFFFFF&sb=FFFFFF&bfg=666666&pbgh=666666&lbgh=666666&sbh=666666&p=0" /></object></object>'
		widget_html.gsub(/_id_/,id)
		widget_html.gsub(/_id_csv_/,id_csv)

	end


	def self.single_song_widget(top_song)
		song_id = top_song['SongID']
		return 0 if song_id.nil?
		widget_html = '<object width="250" height="40" classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" id="gsSong_SONG_ID_26" name="gsSong_SONG_ID_26"><param name="movie" value="http://grooveshark.com/songWidget.swf" /><param name="wmode" value="window" /><param name="allowScriptAccess" value="always" /><param name="flashvars" value="hostname=cowbell.grooveshark.com&songIDs=_SONG_ID_&style=metal&p=0" /><object type="application/x-shockwave-flash" data="http://grooveshark.com/songWidget.swf" width="250" height="40"><param name="wmode" value="window" /><param name="allowScriptAccess" value="always" /><param name="flashvars" value="hostname=cowbell.grooveshark.com&songIDs=_SONG_ID_&style=metal&p=0" /></object></object>'
		widget_html.gsub(/_SONG_ID_/,song_id.to_s)
	
	end


end 




	
#artists

#external-ids

#href
#spotify:track:5CgLtWawyi89C23Oy2lQIj

#length
#376.16

#name
#Closer Than You Know How

#popularity
#0.32585

#track-number
#4

class Spotify
	ROOT_URL = 'http://ws.spotify.com/search/1/track.json?q=artist:'
	def self.find_track(query)
		query = URI.escape(query)
		url = "#{ROOT_URL}#{query}"
		json = JSON.parse(RestClient.get(url))
#		sleep 0.1
		json['tracks'].empty? ? nil : json['tracks'][0]['href'] 		
	rescue
		nil
	end
end 






class Songkick
	
	ROOT_URL = 'http://api.songkick.com/api/3.0/'
	API_PARAM = 'apikey=UokXlLzqCN1zhOWe'
	def self.get_loc_id(city)
		city = URI.escape(city)
		url = "#{ROOT_URL}search/locations.json?query=#{city}&#{API_PARAM}" 
		json = JSON.parse(RestClient.get(url))
		json['resultsPage']['results']['location'][0]['metroArea']['id']  
	end

	def self.venue_seach(query)
		query = URI.escape(query)
		url = "#{ROOT_URL}search/venues.json?query=#{query}&#{API_PARAM}"
		json = JSON.parse(RestClient.get(url))
		json['resultsPage']['results']['venue']

	end


	def self.get_venue_events(query)
		venues = self.venue_seach(query)
		venue_id = venues[0]['id']
		url = "#{ROOT_URL}venues/#{venue_id}/calendar.json?#{API_PARAM}"
		json = JSON.parse(RestClient.get(url))
		json['resultsPage']['results']['event']  

	end

	def self.get_metro_calendar_using_loc_id(loc_id)
		url = "#{ROOT_URL}metro_areas/#{loc_id}/calendar.json?#{API_PARAM}"  
		json = JSON.parse(RestClient.get(url))
		json['resultsPage']['results']['event']  
	end

	def self.get_metro_calendar(city)
		loc_id = self.get_loc_id(city)
		metro_calendar = self.get_metro_calendar_using_loc_id(loc_id)
	end

	def self.get_events_by_city_and_dates(city, min_date, max_date)
		loc_id = self.get_loc_id(city)
		url = "#{ROOT_URL}events.json?location=sk:#{loc_id}&min_date=#{min_date}&max_date=#{max_date}&#{API_PARAM}"
		json = JSON.parse(RestClient.get(url))
		json['resultsPage']['results']['event'] 
	end 
end