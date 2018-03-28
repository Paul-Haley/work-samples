require 'date'
require 'json'
require 'set'
require 'sinatra'

require './linked_list'

set :bind, 'localhost'
set :port, 3000

$devices = Hash.new #TODO: persistent storage

post '/clear_data' do
    $devices = Hash.new
end

post '/:device_id/:epoch_time' do |id, time|
    unless $devices[id]
        $devices[id] = LinkedList.new()
    end
    $devices[id].append(Integer(time))
end

get '/devices' do
    $devices.keys.to_json
end

get '/:device_id/:date' do |id, date|
    if id == 'all'
        puts 'implement all version'
    end
    get_device_time(id, date).to_json
end

get '/:device_id/:from_date/:to_date' do |id, from, to|
    if id == 'all'
        puts 'implement all version'
    end
    get_device_times(id, from, to).to_json
end

#only one date given
def get_device_time(id, from)
    return get_device_times(id, from, (Date.iso8601(from) + 1).strftime("%s"))
end

# when two times/dates are given
def get_device_times(id, from, to)
    node = find_start(id, from)
    list = Array.new
    while node && node.value < to_epoch(to) do
        list.push(node.value)
        break unless node.next
        node = node.next
    end
    return list
end

#given a time or date string, convert to a Integer representing the UNIX time
def to_epoch(dateOrTime)
    return dateOrTime.count('-') > 0 ? Integer(Date.iso8601(dateOrTime).strftime("%s")) : Integer(dateOrTime)
end

#Find where time range starts, if present
#returns starting Node if time present else nil
def find_start(id, from)
    from= to_epoch(from)
    node = $devices[id].head
    while node.next do
        return node if node.value >= from
        node = node.next
    end
    return nil #from time not in list
end
