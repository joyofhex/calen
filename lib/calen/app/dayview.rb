module Calen::App
  class Dayview
    def initialize

    end

    def run(options, ex)
      rooms = ex.rooms_in_site_code(options.sites.first)
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

    private
    def time_iterate(start_time, end_time, step, &block)
      begin
        yield(start_time)
      end while (start_time += step) <= end_time
    end

    def is_time_covered_by_booked_times?(booked_ranges, time)
      !!booked_ranges.detect { |b| b.cover? time }
    end

    def free_symbol(time)
      time.to_i % 3600 == 0 ? '|' : '.'
    end

    def free_busy_per_quarter_hour_display(booked_ranges, start_time, end_time)
      display_string = ''
      time_iterate(start_time, end_time, 900) do |time|
        display_string += is_time_covered_by_booked_times?(booked_ranges, time) ? '*' : free_symbol(time)
      end
      display_string
    end

    def time_header(start_time, end_time, step)
      display_string = ''
      time_iterate(start_time, end_time, 7200) do |time|
        display_string += '|%-7s' % [time.strftime('%H:%M')]
      end
      display_string
    end


  end
end
