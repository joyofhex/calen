require 'spec_helper'
require 'time'
require 'date_ranges'

describe DateRanges do
  describe '#ranges_overlap?' do
    it 'a single range overlaps' do
      date_range = Time.parse('2013-12-05T01:00:00+00:00')..Time.parse('2013-12-05T02:00:00+00:00')
      dr = DateRanges.new

      expect(dr.ranges_overlap?(date_range, date_range)).to be true
    end

    it 'two identical ranges overlap' do
      date_range1 = Time.parse('2013-12-05T01:00:00+00:00')..Time.parse('2013-12-05T02:00:00+00:00')
      date_range2 = Time.parse('2013-12-05T01:00:00+00:00')..Time.parse('2013-12-05T02:00:00+00:00')

      dr = DateRanges.new

      expect(dr.ranges_overlap?(date_range1, date_range2)).to be true
    end

    it 'two widely differing ranges do not overlap' do
      date_range1 = Time.parse('2013-12-05T01:00:00+00:00')..Time.parse('2013-12-05T02:00:00+00:00')
      date_range2 = Time.parse('2013-12-05T03:00:00+00:00')..Time.parse('2013-12-05T04:00:00+00:00')

      dr = DateRanges.new

      expect(dr.ranges_overlap?(date_range1, date_range2)).to be false
    end

    it 'two adjacent ranges overlap' do
      date_range1 = Time.parse('2013-12-05T01:00:00+00:00')..Time.parse('2013-12-05T02:00:00+00:00')
      date_range2 = Time.parse('2013-12-05T02:00:00+00:00')..Time.parse('2013-12-05T04:00:00+00:00')

      dr = DateRanges.new

      expect(dr.ranges_overlap?(date_range1, date_range2)).to be true
    end

    it 'two almost adjacent ranges do not overlap' do
      date_range1 = Time.parse('2013-12-05T01:00:00+00:00')..Time.parse('2013-12-05T02:00:00+00:00')
      date_range2 = Time.parse('2013-12-05T02:00:01+00:00')..Time.parse('2013-12-05T04:00:00+00:00')

      dr = DateRanges.new

      expect(dr.ranges_overlap?(date_range1, date_range2)).to be false
    end

    it 'two overlapping ranges overlap' do
      date_range1 = Time.parse('2013-12-05T01:00:00+00:00')..Time.parse('2013-12-05T02:00:00+00:00')
      date_range2 = Time.parse('2013-12-05T01:30:00+00:00')..Time.parse('2013-12-05T04:00:00+00:00')

      dr = DateRanges.new

      expect(dr.ranges_overlap?(date_range1, date_range2)).to be true
    end
  end

  describe '#merge_ranges' do
    it 'will merge two overlapping ranges when the first range starts before the second range' do
      date_range1 = Time.parse('2013-12-05T01:00:00+00:00')..Time.parse('2013-12-05T02:00:00+00:00')
      date_range2 = Time.parse('2013-12-05T01:30:00+00:00')..Time.parse('2013-12-05T04:00:00+00:00')

      dr = DateRanges.new

      range = dr.merge_ranges date_range1, date_range2

      expect(range.begin).to eq Time.parse('2013-12-05T01:00:00+00:00')
      expect(range.end).to eq Time.parse('2013-12-05T04:00:00+00:00')
    end

    it 'will merge two overlapping ranges when the first range starts after the second range' do
      date_range1 = Time.parse('2013-12-05T01:30:00+00:00')..Time.parse('2013-12-05T04:00:00+00:00')
      date_range2 = Time.parse('2013-12-05T01:00:00+00:00')..Time.parse('2013-12-05T02:00:00+00:00')

      dr = DateRanges.new

      range = dr.merge_ranges date_range1, date_range2

      expect(range.begin).to eq Time.parse('2013-12-05T01:00:00+00:00')
      expect(range.end).to eq Time.parse('2013-12-05T04:00:00+00:00')
    end
  end

  describe '#ranges' do
    it 'will merge two identical ranges into one' do
      date_range = Time.parse('2013-12-05T01:00:00+00:00')..Time.parse('2013-12-05T02:00:00+00:00')
      dr = DateRanges.new
      dr.add_date_range(date_range)
      dr.add_date_range(date_range)

      ranges = dr.ranges
      expect(ranges.count).to eq 1
      expect(ranges.first.begin).to eq Time.parse('2013-12-05T01:00:00+00:00')
      expect(ranges.first.end).to eq Time.parse('2013-12-05T02:00:00+00:00')
    end

    it 'two identical ranges overlap' do
      dr = DateRanges.new
      dr.add_date_range(Time.parse('2013-12-05T01:00:00+00:00')..Time.parse('2013-12-05T02:00:00+00:00'))
      dr.add_date_range(Time.parse('2013-12-05T01:00:00+00:00')..Time.parse('2013-12-05T02:00:00+00:00'))

      ranges = dr.ranges
      expect(ranges.count).to eq 1
      expect(ranges.first.begin).to eq Time.parse('2013-12-05T01:00:00+00:00')
      expect(ranges.first.end).to eq Time.parse('2013-12-05T02:00:00+00:00')
    end

    it 'two widely differing ranges do not overlap' do
      dr = DateRanges.new
      dr.add_date_range(Time.parse('2013-12-05T03:00:00+00:00')..Time.parse('2013-12-05T04:00:00+00:00'))
      dr.add_date_range(Time.parse('2013-12-05T01:00:00+00:00')..Time.parse('2013-12-05T02:00:00+00:00'))

      ranges = dr.ranges
      expect(ranges.count).to eq 2
      expect(ranges[0].begin).to eq Time.parse('2013-12-05T01:00:00+00:00')
      expect(ranges[0].end).to eq Time.parse('2013-12-05T02:00:00+00:00')
      expect(ranges[1].begin).to eq Time.parse('2013-12-05T03:00:00+00:00')
      expect(ranges[1].end).to eq Time.parse('2013-12-05T04:00:00+00:00')
    end

    it 'two adjacent ranges overlap' do
      dr = DateRanges.new
      date_range1 = Time.parse('2013-12-05T01:00:00+00:00')..Time.parse('2013-12-05T02:00:00+00:00')
      date_range2 = Time.parse('2013-12-05T02:00:00+00:00')..Time.parse('2013-12-05T04:00:00+00:00')
      dr.add_date_range(date_range1)
      dr.add_date_range(date_range2)

      ranges = dr.ranges
      expect(ranges.count).to eq 1
      expect(ranges[0].begin).to eq Time.parse('2013-12-05T01:00:00+00:00')
      expect(ranges[0].end).to eq Time.parse('2013-12-05T04:00:00+00:00')
    end

    it 'two almost adjacent ranges do not overlap' do
      date_range1 = Time.parse('2013-12-05T01:00:00+00:00')..Time.parse('2013-12-05T02:00:00+00:00')
      date_range2 = Time.parse('2013-12-05T02:00:01+00:00')..Time.parse('2013-12-05T04:00:00+00:00')

      dr = DateRanges.new
      dr.add_date_range(date_range1)
      dr.add_date_range(date_range2)

      ranges = dr.ranges
      expect(ranges.count).to eq 2
      expect(ranges[0].begin).to eq Time.parse('2013-12-05T01:00:00+00:00')
      expect(ranges[0].end).to eq Time.parse('2013-12-05T02:00:00+00:00')
      expect(ranges[1].begin).to eq Time.parse('2013-12-05T02:00:01+00:00')
      expect(ranges[1].end).to eq Time.parse('2013-12-05T04:00:00+00:00')
    end

    it 'two overlapping ranges overlap' do
      date_range1 = Time.parse('2013-12-05T01:00:00+00:00')..Time.parse('2013-12-05T02:00:00+00:00')
      date_range2 = Time.parse('2013-12-05T01:30:00+00:00')..Time.parse('2013-12-05T04:00:00+00:00')

      dr = DateRanges.new

      dr.add_date_range(date_range1)
      dr.add_date_range(date_range2)

      ranges = dr.ranges
      expect(ranges.count).to eq 1
      expect(ranges[0].begin).to eq Time.parse('2013-12-05T01:00:00+00:00')
      expect(ranges[0].end).to eq Time.parse('2013-12-05T04:00:00+00:00')
    end
  end
end
