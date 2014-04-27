class ExchangeGateway
  class Appointment
    attr_reader :start_time, :end_time, :subject, :location

    def initialize(appointment_data)
      appointment_data = appointment_data[:calendar_event][:elems]
      @start_time = Time.parse find_field(appointment_data, :start_time)
      @end_time = Time.parse find_field(appointment_data, :end_time)
      @status = find_field(appointment_data, :busy_type) || ''

      calendar_event_details = appointment_data.find { |field| field.key? :calendar_event_details }[:calendar_event_details][:elems]
      @subject = find_field(calendar_event_details, :subject) || ''
      @location = find_field(calendar_event_details, :location) || ''
      @recurring = find_field(calendar_event_details, :is_recurring) == "true"
      @private = find_field(calendar_event_details, :is_private) == "true"
    end

    def recurring?
      @recurring
    end

    def private?
      @private
    end

    private
    def find_field(data, field_name)
      data.find { |field| field.key? field_name }[field_name][:text]
    end
  end
end
