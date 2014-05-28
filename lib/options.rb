# encoding: utf-8
require 'optparse'
require 'ostruct'
require 'chronic'
require 'chronic_duration'

class Options
  def initialize(settings)
    @settings = settings
  end

  def parse(args)
    options = OpenStruct.new
    options.sites = []
    options.date = Time.now
    options.length = 3600
    options.mode = :dayview

    option_parser = OptionParser.new do |opts|
      opts.banner = "Usage: calen [options]"

      opts.on '-s', '--site SITE', 'SITE to search for rooms' do |site|
        options.sites << site
      end

      opts.on '-d', '--date DATE', 'DATE to search' do |date|
        options.date = time_at_midnight_on(Chronic.parse(date) || options.date)
      end

      opts.on '--work-day-start-time TIME', 'TIME for the beginning of the day' do |time|
        options.start_time = Chronic.parse(time, now: options.date)
      end

      opts.on '--work-day-end-time TIME', 'TIME for the end of the day' do |time|
        options.end_time = Chronic.parse(time, now: options.date)
      end

      opts.on '-l', '--length DURATION', 'Length of meeting' do |length|
        options.length = ChronicDuration.parse(length)
      end

      # specifying -t makes the tool look for a room at time t, for -l minutes
      opts.on '-t', '--time TIME', 'Start time of the meeting' do |time|
        options.time = Chronic.parse(time, now: options.date)
        options.mode = :freerooms
      end

      opts.on '-a', '--address ADDRESS', 'Address of user to lookup' do |address|
        options.address = address
        options.mode = :list
      end

      opts.on '-m', '--me', 'Lookup up calendar for today' do |me|
        options.mode = :list
        options.address = settings['address']
      end
    end

    option_parser.parse!(args)
    options.start_time ||= Time.parse('08:00', options.date)
    options.end_time ||= Time.parse('18:00', options.date)
    options.sites << 'ODE' if options.sites.count == 0
    options

  end

  def time_at_midnight_on(date)
    Time.gm(date.year, date.month, date.day)
  end

  private
  def settings; @settings; end
end
