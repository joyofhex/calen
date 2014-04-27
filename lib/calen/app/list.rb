module Calen::App
  class List
    attr_accessor :exchange_gateway, :address, :start_time, :end_time

    TABLE_FIELD_WIDTHS = "%-7s %-7s %-30s %-40s"

    def initialize
    end

    def run(options, exchange_gateway)
      @exchange_gateway = exchange_gateway
      @address = options.address
      @start_time = options.start_time
      @end_time = options.end_time
      display(appointment_list)
    end

    private
    def appointment_list
      exchange_gateway.appointment_list_for(address, start_time, end_time)
        .sort { |a,b| a.start_time <=> b.start_time }
    end

    def display(appointment_list)
      header
      appointment_list.each do |appointment|
        puts TABLE_FIELD_WIDTHS % [
          appointment.start_time.strftime("%H:%M"),
          appointment.end_time.strftime("%H:%M"),
          appointment.subject[0..19],
          appointment.location[0..29],
        ]
      end
    end

    def header
      puts "Appointments on #{start_time.to_date}"
      puts TABLE_FIELD_WIDTHS % [
        'Start',
        'End',
        'Subject',
        'Location',
      ]
    end

  end
end
