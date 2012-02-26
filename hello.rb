require 'sinatra'
require 'rest_client'
require 'json'
get '/' do
   response = RestClient.get 'http://ws.audioscrobbler.com/2.0/?method=venue.search&api_key=b25b959554ed76058ac220b7b2e0a026&venue=empty%20bottle&format=json'
   response.to_s
end