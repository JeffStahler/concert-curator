get '/' do 
	erb :index
end 



post '/search' do
  @metro_calendar = Songkick.get_events_by_city_and_dates(params[:city], params[:min_date], params[:max_date])
  erb :search
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