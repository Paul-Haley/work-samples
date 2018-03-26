require 'uri'
require 'date'

require 'json'
require 'set'
require 'sinatra'

set :bind, 'localhost'
set :port, 3000

devices = Hash.new #TODO: persistent storage

post '/clear_data' do
    devices = Hash.new
end

post '/:device_id/:epoch_time' do |id, time|
    unless devices[id]
        devices[id] = SortedSet.new()
    end
    devices[id].add(time)
end

get '/devices' do
    devices.keys.to_json
end
