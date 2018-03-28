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
    node = find_start(id, date)
    list = Array.new
    while node && node.value < Integer((Date.iso8601(date) + 1).strftime("%s")) do
        list.push(node.value)
        break unless node.next
        node = node.next
    end
    list.to_json
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
    puts "Value = " + from.to_s
    while node.next do
        puts node.value.to_s
        return node if node.value >= from
        node = node.next
    end
    return nil #from time not in list
end

# returns array of times in range given
# from and to of string representing ISO8601 date format or seconds since UNIX epoch
def get_range(id, from, to) #FIXME: check what this method is actually for
    from = to_epoch(from)
    to = to_epoch(to)
    to -= 1 #NOTE: to handle exclusive nature of 'to', take a second
    find_start(id, from)
end

def get_range(id, date)
    d = Date.iso8601(date)
    get_range(id, d.strftime("%s"), (d+1).strftime("%s"))
end
