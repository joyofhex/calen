# encoding: utf-8
require 'pry'

require 'spec_helper'
require 'options'

describe Options do
  context 'when multiple sites are provided' do
    it 'returns the sites in the options struct' do
      args = [ '-s', 'ODE', '-s', 'DRK' ]
      option_parser = Options.new
      options = option_parser.parse(args)

      expect(options.sites.count).to eq(2)
      expect(options.sites).to include('ODE')
      expect(options.sites).to include('DRK')
    end
  end

  context 'when no date is given' do
    it 'should select today as the date' do
      args = []
      today = Time.now
      option_parser = Options.new
      options = option_parser.parse(args)

      expect(options.date.year).to eq(today.year)
      expect(options.date.month).to eq(today.month)
      expect(options.date.day).to eq(today.day)
    end
  end

  context 'when a date is specified' do
    it 'should be in the options date structure' do
      args = [ '-d', '2013-12-01']
      today = Time.parse('2013-12-01')
      option_parser = Options.new
      options = option_parser.parse(args)

      expect(options.date.year).to eq(today.year)
      expect(options.date.month).to eq(today.month)
      expect(options.date.day).to eq(today.day)
    end
  end

  context 'when an invalid date is used' do
    it 'should use today as a default' do
      args = [ '-d', 'dingleberry' ]
      today = Time.now
      option_parser = Options.new
      options = option_parser.parse(args)

      expect(options.date.year).to eq(today.year)
      expect(options.date.month).to eq(today.month)
      expect(options.date.day).to eq(today.day)
    end
  end

end
