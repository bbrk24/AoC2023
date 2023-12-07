using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.Linq;

public static class Program
{
    private static Map ParseMap(string str)
    {
        // Split into lines. First line is the label so ignore it.
        var lines = str.Split('\n')
            .Skip(1)
        // Parse each line
            .Select(line =>
            {
                var numbers = line.Split(' ');
                long destStart = long.Parse(numbers[0]),
                    srcStart = long.Parse(numbers[1]),
                    length = long.Parse(numbers[2]);
                return (destStart, srcStart, length);
            });
        // Convert to Map object
        return new(lines);
    }

    public static long F(string input)
    {
        var pieces = input.Split("\n\n", StringSplitOptions.TrimEntries);

        var seedSoilMap = ParseMap(pieces[1]);
        var soilFertilizerMap = ParseMap(pieces[2]);
        var fertilizerWaterMap = ParseMap(pieces[3]);
        var waterLightMap = ParseMap(pieces[4]);
        var lightTemperatureMap = ParseMap(pieces[5]);
        var temperatureHumidityMap = ParseMap(pieces[6]);
        var humidityLocationMap = ParseMap(pieces[7]);

        // Parse out the numbers
        var seeds = pieces[0].Split(' ')
            .Skip(1)
            .Select(long.Parse)
        // Convert to ranges
            .Chunk(2)
            .Select(pair => new LongRange(pair[0], pair[1]));

        RangeSet seedsSet = new(seeds);

        RangeSet soilSet = new(seedsSet.Ranges.SelectMany(seedSoilMap.GetRanges));
        RangeSet fertilizerSet = new(soilSet.Ranges.SelectMany(soilFertilizerMap.GetRanges));
        RangeSet waterSet = new(fertilizerSet.Ranges.SelectMany(fertilizerWaterMap.GetRanges));
        RangeSet lightSet = new(waterSet.Ranges.SelectMany(waterLightMap.GetRanges));
        RangeSet temperatureSet = new(lightSet.Ranges.SelectMany(lightTemperatureMap.GetRanges));
        RangeSet humiditySet = new(temperatureSet.Ranges.SelectMany(temperatureHumidityMap.GetRanges));
        RangeSet locationSet = new(humiditySet.Ranges.SelectMany(humidityLocationMap.GetRanges));

        return locationSet.Min();
    }

    // I know I'm boxing a non-readonly struct, but I really need value semantics
    struct LongRange
    {
        public long Start;
        public long Count;

        public LongRange(long start, long count)
        {
            Start = start;
            Count = count;
        }
    }

    class RangeSet
    {
        private List<LongRange> _ranges;

        public IEnumerable<LongRange> Ranges => _ranges;
        public long Min() => _ranges[0].Start;

        public RangeSet(IEnumerable<LongRange> ranges)
        {
            _ranges = ranges.OrderBy(x => x.Start)
                .ToList();
            Simplify();
        }

        private void Simplify()
        {
            var newRanges = new List<LongRange> { _ranges.First() };

            foreach (var range in _ranges.Skip(1))
            {
                var last = newRanges.Last();
                if (last.Start + last.Count >= range.Start)
                    last.Count = range.Start + range.Count - last.Start;
                else
                    newRanges.Add(range);
            }

            _ranges = newRanges;
        }
    }

    readonly struct Map
    {
        private readonly ImmutableArray<(long DestStart, long SrcStart, long Length)> _values;

        public Map(IEnumerable<(long DestStart, long SrcStart, long Length)> values)
        {
            _values = values.OrderBy(x => x.SrcStart)
                .ToImmutableArray();
        }

        // The smallest index for where SrcStart <= x, or -1 on failure
        private int GetIndex(long x)
        {
            if (_values[0].SrcStart > x) return -1;
            if (_values.Last().SrcStart <= x) return _values.Length - 1;

            // Binary search
            int high = _values.Length, low = 0;
            while (high > low)
            {
                var mid = (high + low) / 2;
                var value = _values[mid];
                if (value.SrcStart > x)
                {
                    // SrcStart is too high, reduce the range
                    high = mid;
                }
                else
                {
                    // This item might be it, but might not be.
                    // Bring the low end up if possible, but if we've already
                    // eliminated everything else, this must be it.
                    if (low == mid) break;
                    low = mid;
                }
            }
            return low;
        }

        public IEnumerable<LongRange> GetRanges(LongRange r)
        {
            var i = GetIndex(r.Start);

            // Each section of the range is either 'unhandled' or 'transformed'.
            // Initialize this value to indicate whether the range starts in an unhandled section.
            bool unhandled = i < 0
                || i >= _values.Length
                || r.Start >= _values[i].SrcStart + _values[i].Length;

            // Alternate:
            while (r.Count > 0)
            {
                // 1. grab unhandled part
                if (unhandled)
                {
                    bool lastPart = i + 1 >= _values.Length;
                    if (lastPart)
                    {
                        // We've reached the end of the array
                        yield return r;
                        yield break;
                    }
                    else
                    {
                        var next = _values[i + 1].SrcStart;
                        if (r.Start + r.Count > next)
                        {
                            // only part of this is unhandled
                            LongRange unhandledPart = new(r.Start, next - r.Start);
                            yield return unhandledPart;

                            r = new(next, r.Count - unhandledPart.Count);
                            i += 1;
                        }
                        else
                        {
                            // the range doesn't reach the next part
                            yield return r;
                            yield break;
                        }
                    }
                }

                // 2. Grab the transformed part
                var transformEnd = _values[i].SrcStart + _values[i].Length;
                if (r.Start + r.Count <= transformEnd)
                {
                    // the whole thing is transformed
                    yield return new LongRange(
                        _values[i].DestStart + r.Start - _values[i].SrcStart,
                        r.Count
                    );
                    yield break;
                }
                else
                {
                    LongRange transformedPart = new(
                        _values[i].DestStart + r.Start - _values[i].SrcStart,
                        transformEnd - r.Start
                    );
                    yield return transformedPart;

                    r = new(transformEnd, r.Count - transformedPart.Count);
                    unhandled = true;
                }
            }
        }
    }
}
