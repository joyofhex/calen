# encoding: utf-8
require 'viewpoint'
require 'time'
require 'exchange_gateway/appointment'

class ExchangeGateway
  include Viewpoint::EWS

  def initialize(endpoint, settings)
    Viewpoint::EWS.root_logger.level = :warn
    @cli = Viewpoint::EWSClient.new endpoint, settings['username'], settings['password'], http_opts: { trust_ca: [ settings['ca'] ] }
    @timezone = 'W. Europe Standard Time'
    @cli.set_time_zone timezone
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

  def bulk_room_availability(addresses, start_time, end_time)
    # addresses.each do |room|
    #   room[:booked] = room_availability room[:address], start_time, end_time
    # end
    # addresses
    bulk_appointments_in_range addresses, start_time, end_time
  end

  def user_availability(address, start_time, end_time)
    availability = appointments_in_range(address, start_time, end_time)
    availability.calendar_event_array.map do |event|
      time_range_for_calendar_event(event[:calendar_event][:elems])
    end
  end

  def appointment_list_for(address, start_time, end_time)
    appointments_in_range(address, start_time, end_time).calendar_event_array.map do |event|
      ExchangeGateway::Appointment.new(event)
    end
  end

  def bulk_appointments_in_range(addresses, start_time, end_time)
    bias = 0
    avail = cli.get_user_availability(
      addresses.map { |a| a[:address] },
      start_time: start_time.iso8601,
      end_time: end_time.iso8601,
      requested_view: :detailed,
      time_zone: { bias: bias }
    )
    availability_by_room = avail.body[0][:get_user_availability_response][:elems][0][:free_busy_response_array][:elems]
    appointments_by_room = []
    addresses.each_with_index do |address,index|
      calendar_events = availability_by_room[index][:free_busy_response][:elems][1][:free_busy_view][:elems][1]

      if calendar_events and calendar_events.has_key? :calendar_event_array
        range = calendar_events[:calendar_event_array][:elems].map do |event|
          time_range_for_calendar_event(event[:calendar_event][:elems])
        end
      else
        range = []
      end

      appointments_by_room << {
        name: address[:name],
        address: address[:address],
        booked: range,
      }
    end
    appointments_by_room
  end

  def appointments_in_range(address, start_time, end_time)
    bias = 0
    cli.get_user_availability(
      [address],
      start_time: start_time.iso8601,
      end_time: end_time.iso8601,
      requested_view: :detailed,
      time_zone: { bias: bias }
    )
  end

  def time_range_for_calendar_event(event)
    start_time = event.detect { |g| g.has_key? :start_time }[:start_time][:text]
    end_time = event.detect { |g| g.has_key? :end_time }[:end_time][:text]
    Time.parse(start_time)...Time.parse(end_time)
  end

  private

  def timezone; @timezone; end

  def cli
    @cli
  end

end
