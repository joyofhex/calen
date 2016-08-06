# encoding: utf-8

require 'time'

class DateRanges
  attr_accessor :dates

  def initialize
    @date_ranges = []
  end

  def add_date_range(range)
    @date_ranges << range
  end

  def ranges
    @date_ranges.sort_by(&:begin).inject([]) do |ranges, range|
      if !ranges.empty? && ranges_overlap?(ranges.last, range)
        ranges[0...-1] + [merge_ranges(ranges.last, range)]
      else
        ranges + [range]
      end
    end
  end

  def ranges_overlap?(a, b)
    a.cover?(b.begin) || b.cover?(a.begin)
  end

  def merge_ranges(a, b)
    [a.begin, b.begin].min..[a.end, b.end].max
  end
end
