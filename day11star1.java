import java.util.ArrayList;
import java.util.Arrays;

public class Main {
    static class Point {
        public int x;
        public int y;

        public Point(int x, int y) {
            this.x = x;
            this.y = y;
        }
    }

    private static int countInRange(
        int start,
        int stop,
        int[] arr
    ) {
        int trueStart = Math.min(start, stop);
        int trueStop = Math.max(start, stop);

        int endIndex = Arrays.binarySearch(arr, trueStop);
        if (endIndex < 0) {
            endIndex = ~endIndex;
        }
        int startIndex = Arrays.binarySearch(arr, 0, endIndex, trueStart);
        if (startIndex < 0) {
            startIndex = ~startIndex;
        }
        return endIndex - startIndex;
    }

    public static int f(String arg) {
        String[] lines = arg.split("\n");

        ArrayList<Integer> emptyLines = new ArrayList<Integer>();
        for (int i = 0; i < lines.length; ++i) {
            if (!lines[i].contains("#")) {
                emptyLines.add(i);
            }
        }

        ArrayList<Integer> emptyColumns = new ArrayList<Integer>();
        for (int i = 0; i < lines[0].length(); ++i) {
            boolean empty = true;
            for (int j = 0; j < lines.length; ++j) {
                if (lines[j].charAt(i) == '#') {
                    empty = false;
                    break;
                }
            }

            if (empty) {
                emptyColumns.add(i);
            }
        }

        ArrayList<Point> galaxyLocations = new ArrayList<Point>();
        for (int i = 0; i < lines.length; ++i) {
            for (int j = 0; j < lines[i].length(); ++j) {
                if (lines[i].charAt(j) == '#') {
                    galaxyLocations.add(new Point(j, i));
                }
            }
        }

        int total = 0;
        int[] emptyLinesArr = emptyLines.stream().mapToInt(Integer::intValue).toArray();
        int[] emptyColumnsArr = emptyColumns.stream().mapToInt(Integer::intValue).toArray();
        for (Point p1 : galaxyLocations) {
            for (Point p2 : galaxyLocations) {
                int length = Math.abs(p1.x - p2.x) + Math.abs(p1.y - p2.y);
                length += countInRange(p1.x, p2.x, emptyColumnsArr);
                length += countInRange(p1.y, p2.y, emptyLinesArr);
                total += length;
            }
        }
        
        return total / 2;
    }
}