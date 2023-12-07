using System;
using System.Linq;
using System.Collections.Generic;

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

        var seeds = pieces[0].Split(' ')
            .Skip(1)
            .Select(long.Parse);

        long bestSeedLoc = long.MaxValue;
        foreach (var seed in seeds)
        {
            var seedLoc = humidityLocationMap[
                temperatureHumidityMap[
                    lightTemperatureMap[
                        waterLightMap[
                            fertilizerWaterMap[
                                soilFertilizerMap[
                                    seedSoilMap[
                                        seed
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ];


            if (seedLoc < bestSeedLoc) bestSeedLoc = seedLoc;
        }

        return bestSeedLoc;
    }

    class Map
    {
        private readonly List<(long DestStart, long SrcStart, long Length)> _values;

        public Map(IEnumerable<(long DestStart, long SrcStart, long Length)> values)
        {
            _values = values.ToList();
        }

        public long this[long index]
        {
            get
            {
                foreach (var triple in _values)
                {
                    if (index >= triple.SrcStart && index < triple.SrcStart + triple.Length)
                        return triple.DestStart + index - triple.SrcStart;
                }
                return index;
            }
        }
    }
}
