
/**
 * @param {string} line
 */
function parseLine(line) {
    let red = 0, blue = 0, green = 0;
    const matches = line
        .split(':')[1]
        .matchAll(/\s(\d+)\s(red|green|blue)/g);

    for (const match of matches) {
        switch (match[2]) {
        case 'red':
            red = Math.max(red, +match[1]);
            break;
        case 'green':
            green = Math.max(green, +match[1]);
            break;
        case 'blue':
            blue = Math.max(blue, +match[1]);
            break;
        }
    }

    return { red, green, blue };
}

/**
 * @param {string} input
 */
function f(input) {
    let total = 0;
    for (const line of input.split('\n')) {
        if (line) {
            const { red, green, blue } = parseLine(line);
            const power = red * green * blue;
            total += power;
        }
    }
    return total;
}
