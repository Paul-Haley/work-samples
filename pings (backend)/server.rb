require 'date'
require 'json'
require 'set'
require 'sinatra'

require './linked_list'

set :bind, 'localhost'
set :port, 3000

$devices = Hash.new #TODO: persistent storage/DB

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
    unless (id == 'all' || $devices.keys.include?(id)) && is_time(date)
        return Array.new.to_json
    end
    unless id == 'all'
        return get_device_time(id, date).to_json
    end
    all = Hash.new
    $devices.keys.each do |id|
        all[id] = get_device_time(id, date)
    end
    Hash[all.sort_by {|key, val| key }].to_json
end

get '/:device_id/:from_date/:to_date' do |id, from, to|
    unless (id == 'all' || $devices.keys.include?(id)) && is_time(from) && is_time(to)
        return Array.new.to_json
    end
    unless id == 'all'
        return get_device_times(id, from, to).to_json
    end
    all = Hash.new
    $devices.keys.each do |id|
        all[id] = get_device_times(id, from, to)
    end
    Hash[all.sort_by {|key, val| key }].to_json
end

# dirty code to check if a int (seconds since UNIX epoch) or valid date given
def is_time(time)
    return Integer(time) rescue
    return Date.iso8601(time) rescue
    false
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
