#include <stdbool.h>
#include <stddef.h>
#include <stdlib.h>
#include <string.h>

// Exclamation point key broke
#include <iso646.h>

#define OFFSET(x, y, cols) ((x) + (y) * ((cols) + 1))

static inline void get_location(
    size_t index,
    size_t cols,
    size_t *restrict x,
    size_t *restrict y
) {
    *x = index % (cols + 1);
    *y = index / (cols + 1);
}

static inline const char* advance(const char* curr, const char* old, ptrdiff_t cols) {
    ptrdiff_t y_offset = cols + 1;

    switch (*curr) {
    case '|':
        if (old < curr) {
            return curr + y_offset;
        } else {
            return curr - y_offset;
        }
    case '-':
        if (old < curr) {
            return curr + 1;
        } else {
            return curr - 1;
        }
    case 'L':
        if (old < curr) {
            return curr + 1;
        } else {
            return curr - y_offset;
        }
    case 'J':
        if (curr - old > 1) {
            return curr - 1;
        } else {
            return curr - y_offset;
        }
    case '7':
        if (old < curr) {
            return curr + y_offset;
        } else {
            return curr - 1;
        }
    case 'F':
        if (old - curr > 1) {
            return curr + 1;
        } else {
            return curr + y_offset;
        }
    }
}

static inline int f(const char* str) {
    ptrdiff_t line_length = strchr(str, '\n') - str;
    size_t str_length = strlen(str);
    size_t num_rows = str_length / line_length;
    ptrdiff_t s_index = strchr(str, 'S') - str;
    size_t s_x, s_y;
    get_location(s_index, line_length, &s_x, &s_y);

    bool* in_main_loop = (bool*)calloc(str_length, sizeof (bool));

    // Raycast to the right, counting |LJ as 1 and -F7 as 0
    // means we have to track whether the starting point has a top connection
    bool start_has_top = false;

    const char *first = NULL, *second = NULL;
#define ASSIGN_FIRST_NOT_NULL(ptr) \
    do { \
        if (first == NULL) { \
            first = (ptr); \
        } else { \
            second = (ptr); \
        } \
    } while (false)

    if (s_index not_eq 0 &&
        (str[s_index - 1] == '-' || str[s_index - 1] == 'F' || str[s_index - 1] == 'L')) {
        ASSIGN_FIRST_NOT_NULL(str + s_index - 1);
    }
    if (str[s_index + 1] == '-' || str[s_index + 1] == '7' ||
        str[s_index + 1] == 'J') {
        ASSIGN_FIRST_NOT_NULL(str + s_index + 1);
    }
    if (s_y not_eq 0 && (str[OFFSET(s_x, s_y - 1, line_length)] == '|' ||
                         str[OFFSET(s_x, s_y - 1, line_length)] == 'F' ||
                         str[OFFSET(s_x, s_y - 1, line_length)] == '7')) {
        start_has_top = true;
        ASSIGN_FIRST_NOT_NULL(str + OFFSET(s_x, s_y - 1, line_length));
    }
    if (s_y + 1 not_eq num_rows &&
        (str[OFFSET(s_x, s_y + 1, line_length)] == '|' ||
         str[OFFSET(s_x, s_y + 1, line_length)] == 'J' ||
         str[OFFSET(s_x, s_y + 1, line_length)] == 'L')) {
        ASSIGN_FIRST_NOT_NULL(str + OFFSET(s_x, s_y + 1, line_length));
    }

    in_main_loop[s_index] = true;

#undef ASSIGN_FIRST_NOT_NULL

    const char *old_first = str + s_index;
    const char *old_second = old_first;

    while (first not_eq second && first not_eq old_second) {
        in_main_loop[first - str] = true;
        in_main_loop[second - str] = true;

        const char* new_first = advance(first, old_first, line_length);
        const char* new_second = advance(second, old_second, line_length);

        old_first = first;
        first = new_first;
        old_second = second;
        second = new_second;
    }
    // off-by-one
    in_main_loop[first - str] = true;
    in_main_loop[second - str] = true;

    int counter = 0;

    for (size_t i = 0; i < str_length; ++i) {
        if (in_main_loop[i] || str[i] == '\0' || str[i] == '\n') {
            continue;
        }
        short row_counter = 0;
        for (size_t j = i; str[j] not_eq '\0' && str[j] not_eq '\n'; ++j) {
            if (not in_main_loop[j]) {
                continue;
            }
            if (str[j] == '|' || str[j] == 'L' || str[j] == 'J') {
                ++row_counter;
            } else if (str[j] == 'S' && start_has_top) {
                ++row_counter;
            }
        }
        // if row_counter is even, it's outside
        // if odd, it's inside
        counter += row_counter % 2;
    }

    free(in_main_loop);
    return counter;
}
