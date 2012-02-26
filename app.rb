get '/' do 
	erb :index
end 



post '/search' do
  @metro_calendar = Songkick.get_metro_calendar(params[:city])
  erb :search
end



class Songkick
	
	API_KEY = 'UokXlLzqCN1zhOWe'
	ROOT_URL = 'http://api.songkick.com/api/3.0/'
	def self.get_loc_id(city)
		city = URI.escape(city)
		url = "#{ROOT_URL}search/locations.json?query=#{city}&apikey=#{API_KEY}" 
		parsed_json_response = JSON.parse(RestClient.get(url))
		loc_id = parsed_json_response['resultsPage']['results']['location'][0]['metroArea']['id']  
	end

	def self.get_metro_calendar_using_loc_id(loc_id)
		url = "#{ROOT_URL}metro_areas/#{loc_id}/calendar.json?apikey=#{API_KEY}"  
		parsed_json_response = JSON.parse(RestClient.get(url))
		metro_calendar = parsed_json_response['resultsPage']['results']['event']  
	end

	def self.get_metro_calendar(city)
		loc_id = self.get_loc_id(city)
		metro_calendar = self.get_metro_calendar_using_loc_id(loc_id)
	end



end 