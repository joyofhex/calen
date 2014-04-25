module Calen::App
  class Dayview
    def initialize

    end

    def run(options, ex, rooms)
      start_time = options.start_time
      end_time = options.end_time

      rooms.each do |room|
        room[:booked] = ex.room_availability room[:address], start_time, end_time
      end

      puts 'Room Availability on %s from %s until %s' % [
        start_time.strftime('%F'),
        start_time.strftime('%R'),
        end_time.strftime('%R'),
      ]
      puts '%-30s ' % [ 'Room' ] + time_header(start_time, end_time, 7200)
      rooms.each do |room|
        room_name_field = "%-29s" % [ room[:name][0..28] ]
        puts room_name_field + ': ' + free_busy_per_quarter_hour_display(room[:booked], start_time, end_time)
      end
    end
  end
end
