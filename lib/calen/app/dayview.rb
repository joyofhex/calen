require 'io/console'
require 'date_ranges'

module Calen::App
  class Dayview
    SECONDS_BETWEEN_HEADER_ENTRIES = 7200
    DURATION_OF_EACH_OUTPUT_CHARACTER = 900
    MINIMUM_WIDTH = 60

    def initialize

    end

    def run(options, exchange_gateway)
      rooms = exchange_gateway.rooms_in_site_code(options.sites.first)
      start_time = options.start_time
      end_time = options.end_time

      rooms.each do |room|
        room[:booked] = exchange_gateway.room_availability room[:address], start_time, end_time
      end

      time_header = time_header(start_time, end_time, SECONDS_BETWEEN_HEADER_ENTRIES)
      room_name_field_width = calculate_room_name_field_width(time_header.length, rooms)

      puts 'Room Availability on %s from %s until %s' % [
        start_time.strftime('%F'),
        start_time.strftime('%R'),
        end_time.strftime('%R'),
      ]
      puts "%-#{room_name_field_width+2}s " % [ 'Room' ] + time_header
      rooms.each do |room|
        room_name_field = "%-#{room_name_field_width+1}s" % [ room[:name][0..room_name_field_width] ]
        puts room_name_field + ': ' + free_busy_per_quarter_hour_display(room[:booked], start_time, end_time)
      end
    end

    private
    def calculate_room_name_field_width(columns, time_header_length, rooms)
      columns = console_window_width
      columns = MINIMUM_WIDTH if columns < MINIMUM_WIDTH

      room_name_max_field_width = columns - time_header_length
      room_name_max_length = rooms.max { |a,b| a[:name].length <=> b[:name].length }[:name].length
      [ room_name_max_field_width, room_name_max_length + 2 ].min
    end

    def console_window_width
      IO.console.winsize[1]
    end

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
      time_iterate(start_time, end_time, DURATION_OF_EACH_OUTPUT_CHARACTER) do |time|
        display_string += is_time_covered_by_booked_times?(booked_ranges, time) ? '*' : free_symbol(time)
      end
      display_string
    end

    def time_header(start_time, end_time, step)
      display_string = ''
      time_iterate(start_time, end_time, step) do |time|
        display_string += '|%-7s' % [time.strftime('%H:%M')]
      end
      display_string
    end

  end
end
