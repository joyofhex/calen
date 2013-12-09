# encoding: utf-8
require 'viewpoint'
require 'time'

include Viewpoint::EWS


class ExchangeGateway
  include Viewpoint::EWS

  def initialize(endpoint, settings)
    Viewpoint::EWS.root_logger.level = :warn
    @cli = Viewpoint::EWSClient.new endpoint, settings['username'], settings['password'] 
  end

  def room_lists
    @room_lists ||= Hash[*cli.get_room_lists.roomListsArray.map { |f| [ f[:address][:elems][:name][:text], f[:address][:elems][:email_address][:text] ]  }.flatten ]
  end

  def room_list_addresses_for_site_code(site_code)
    room_lists.select { |k,v| k.match(/#{site_code}/) }.values
  end

  def rooms_in_room_list(room_list_address)
    rooms = cli.get_rooms(room_list_address)
    rooms.roomsArray.map do |e| 
      {
        name: e[:room][:elems][:id][:elems].detect { |k,v| k.has_key? :name }[:name][:text], 
        address: e[:room][:elems][:id][:elems].detect { |k,v| k.has_key? :email_address }[:email_address][:text],
      }
    end
  end

  def rooms_in_room_lists(room_list_addresses)
    room_list_addresses.inject([]) { |room_list,address|
      room_list.concat rooms_in_room_list(address)
    }.sort_by { |entry| entry[:name] }
  end

  def rooms_in_site_code(site_code)
    rooms_in_room_lists(room_list_addresses_for_site_code(site_code))
  end

  def room_availability(address, start_time, end_time)
    user_availability(address, start_time, end_time)
  end

  def user_availability(address, start_time, end_time)
    bias = -( start_time.utc_offset / 60 )
    availability = cli.get_user_availability([address], start_time: start_time, end_time: end_time, requested_view: :free_busy, time_zone: { bias: bias })
    availability.calendar_event_array.map do |event|
      time_range_for_calendar_event(event[:calendar_event][:elems])
    end
  end

  def time_range_for_calendar_event(event)
    start_time = event.detect { |g| g.has_key? :start_time }[:start_time][:text]
    end_time = event.detect { |g| g.has_key? :end_time }[:end_time][:text]
    Time.parse(start_time)...Time.parse(end_time)
  end

  def cli
    @cli
  end

end
