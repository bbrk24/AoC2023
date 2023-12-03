#include <cstring>
#include <vector>
#include <unordered_map>
#include <utility>

namespace std {
template<>
struct hash<pair<size_t, size_t> > {
    size_t operator()(const pair<size_t, size_t>& arg) const noexcept {
        return arg.first ^ ((arg.second << 4 * sizeof (size_t)) | (arg.first >> 4 * sizeof (size_t)));
    }
};
}

struct TextRange {
    size_t row;
    size_t startCol;
    size_t endCol;
};

constexpr bool isDigit(char d) noexcept {
    return d >= '0' && d <= '9';
}

std::vector<TextRange> getNumberRanges(
    const char** text,
    size_t rows,
    size_t cols
) noexcept {
    std::vector<TextRange> result;

    for (size_t i = 0; i < rows; ++i) {
        bool currentlyNumber = false;
        size_t start = 0;

        for (size_t j = 0; j < cols; ++j) {
            if (isDigit(text[i][j])) {
                if (!currentlyNumber) {
                    start = j;
                    currentlyNumber = true;
                }
            } else {
                if (currentlyNumber) {
                    result.push_back({ i, start, j });
                    currentlyNumber = false;
                }
            }
        }
        if (currentlyNumber) {
            result.push_back({ i, start, cols });
        }
    }

    return result;
}

bool isAdjacentGear(
    const TextRange& range,
    const char** text,
    size_t rows,
    size_t cols,
    std::pair<size_t, size_t>& gearLoc
) noexcept {
    bool scanPrevRow = (range.row != 0);
    bool scanPrevCol = (range.startCol != 0);
    bool scanNextRow = (range.row + 1 != rows);
    bool scanNextCol = (range.endCol != cols);

    if (scanPrevRow) {
        for (size_t i = range.startCol; i < range.endCol; ++i) {
            if (text[range.row - 1][i] == '*') {
                gearLoc = { range.row - 1, i };
                return true;
            }
        }
    }
    if (scanPrevCol) {
        if (text[range.row][range.startCol - 1] == '*') {
            gearLoc = { range.row, range.startCol - 1 };
            return true;
        }
        if (scanPrevRow && text[range.row - 1][range.startCol - 1] == '*') {
            gearLoc = { range.row - 1, range.startCol - 1 };
            return true;
        }
        if (scanNextRow && text[range.row + 1][range.startCol - 1] == '*') {
            gearLoc = { range.row + 1, range.startCol - 1 };
            return true;
        }
    }
    if (scanNextRow) {
        for (size_t i = range.startCol; i < range.endCol; ++i) {
            if (text[range.row + 1][i] == '*') {
                gearLoc = { range.row + 1, i };
                return true;
            }
        }
    }
    if (scanNextCol) {
        if (text[range.row][range.endCol] == '*') {
            gearLoc = { range.row, range.endCol };
            return true;
        }
        if (scanPrevRow && text[range.row - 1][range.endCol] == '*') {
            gearLoc = { range.row - 1, range.endCol };
            return true;
        }
        if (scanNextRow && text[range.row + 1][range.endCol] == '*') {
            gearLoc = { range.row + 1, range.endCol };
            return true;
        }
    }
    return false;
}

unsigned long parseNumber(
    const TextRange& range,
    const char** text
) noexcept {
    unsigned long result = 0;
    for (size_t i = range.startCol; i < range.endCol; ++i) {
        result *= 10;
        result += text[range.row][i] - '0';
    }
    return result;
}

unsigned long f(const char* input) noexcept {
    size_t rowLen = strchr(input, '\n') - input;
    size_t rowCount = strlen(input) / rowLen;

    // I don't feel like going back and fixing the other functions to take char* rather than char**
    const char** rows = new const char*[rowCount];
    for (size_t i = 0; i < rowCount; ++i) {
        rows[i] = input + (rowLen + 1) * i;
    }

    std::unordered_map<std::pair<size_t, size_t>, std::vector<TextRange> > gearNumbers;

    for (const auto& r : getNumberRanges(rows, rowCount, rowLen)) {
        std::pair<size_t, size_t> gearLoc;
        if (isAdjacentGear(r, rows, rowCount, rowLen, gearLoc)) {
            auto loc = gearNumbers.find(gearLoc);
            if (loc != gearNumbers.end()) {
                loc->second.push_back(r);
            } else {
                gearNumbers.insert({ gearLoc, { r } });
            }
        }
    }

    unsigned long total = 0;

    for (const auto& pair : gearNumbers) {
        if (pair.second.size() != 2) {
            continue;
        }

        total += parseNumber(pair.second[0], rows) * parseNumber(pair.second[1], rows);
    }

    delete[] rows;
    return total;
}
