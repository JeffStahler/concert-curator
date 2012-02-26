get '/' do 
	erb :index
end 



post '/search' do
  @metro_calendar = Songkick.get_events_by_city_and_dates(params[:city], params[:min_date], params[:max_date])
  erb :search
end

post '/grooveshark' do 
  @song = Grooveshark.get_top_song(params[:query])
  erb :grooveshark
end



class Grooveshark
	ROOT_URL = 'http://tinysong.com/b/'
	FORMAT = '?format=json'
	API_PARAM = 'key=69cd853e5352c9d96db26925c3c770f6'

	def self.get_top_song(query)
		query = URI.escape(query)
		 
		url = "#{ROOT_URL}#{query}&#{FORMAT}&#{API_PARAM}"
		json = JSON.parse(RestClient.get(url))

		json['Song_Widget'] = self.single_song_widget(json['SongID']) 
		json 
#		{"Url":"http:\/\/tinysong.com\/knej","SongID":13963,"SongName":"Ask About Me","ArtistID":77,"ArtistName":"Girl Talk","AlbumID":117512,"AlbumName":"Night Ripper"}
#		http://tinysong.com/b/Girl+Talk+Ask+About+Me?format=json&key=APIKey
	end

	def self.single_song_widget(song_id)
	
		widget_html = '<object width="250" height="40" classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" id="gsSong_SONG_ID_26" name="gsSong_SONG_ID_26"><param name="movie" value="http://grooveshark.com/songWidget.swf" /><param name="wmode" value="window" /><param name="allowScriptAccess" value="always" /><param name="flashvars" value="hostname=cowbell.grooveshark.com&songIDs=_SONG_ID_&style=metal&p=0" /><object type="application/x-shockwave-flash" data="http://grooveshark.com/songWidget.swf" width="250" height="40"><param name="wmode" value="window" /><param name="allowScriptAccess" value="always" /><param name="flashvars" value="hostname=cowbell.grooveshark.com&songIDs=_SONG_ID_&style=metal&p=0" /></object></object>'
		widget_html.gsub(/_SONG_ID_/,song_id.to_s)

	
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