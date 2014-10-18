module Calen::App
  class FreeRooms
    def initialize
    end

    def run(options, exchange_gateway)
      rooms = exchange_gateway.rooms_in_site_code(options.sites.first)
      start_time = options.time
      end_time = options.time + options.length

      rooms = exchange_gateway.bulk_room_availability rooms, start_time, end_time

      puts 'Available rooms on %s at %s for %s (ending at %s)' % [
        start_time.strftime('%F'),
        start_time.strftime('%R'),
        ChronicDuration.output(options.length),
        end_time.strftime('%R'),
      ]

      rooms.each do |room|
        puts "\t" + room[:name] if room[:booked].length == 0
      end
    end
  end
end
