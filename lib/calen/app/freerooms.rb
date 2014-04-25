module Calen::App
  class FreeRooms
    def initialize
    end

    def run(options, ex, rooms)
      start_time = options.time
      end_time = options.time + options.length

      rooms.each do |room|
        room[:booked] = ex.room_availability room[:address], start_time, end_time
      end

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
