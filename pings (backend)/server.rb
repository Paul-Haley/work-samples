require 'date'
require 'json'
require 'set'
require 'sinatra'

require './linked_list'

set :bind, 'localhost'
set :port, 3000

devices = Hash.new #TODO: persistent storage

post '/clear_data' do
    devices = Hash.new
end

post '/:device_id/:epoch_time' do |id, time|
    unless devices[id]
        devices[id] = LinkedList.new()
    end
    devices[id].add(Integer(time))
end

get '/devices' do
    devices.keys.to_json
end

get '/:device_id/:date' do |id, date|
    if id == 'all'
        puts 'implement all version'
    end
    #TODO: finish implementation
end

#Find where time range starts, if present
#returns starting Node if time present else nil
def find_start(id, from)
    list = devices[id]
    #TODO: finish implementation
end

# returns array of times in range given
# from and to of string representing ISO8601 date format or seconds since UNIX epoch
def get_range(id, from, to)
    if from.count('-') > 0 && to.count('-') > 0
        from = Integer(Date.iso8601(from).strftime("%s"))
        to = Integer(Date.iso8601(to).strftime("%s"))
    else
        from = Integer(from)
        to = Integer(to)
    end
    to -= 1 #NOTE: to handle exclusive nature of 'to', take a second

end

def get_range(id, date)
    d = Date.iso8601(date)
    get_range(id, d.strftime("%s"), (d+1).strftime("%s"))
end
