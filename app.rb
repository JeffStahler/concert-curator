get '/' do
  url = 'http://ws.audioscrobbler.com/2.0/?method=venue.search&api_key=b25b959554ed76058ac220b7b2e0a026&venue=empty%20bottle&format=json'
  @data = JSON.parse(RestClient.get(url))['results']
end
