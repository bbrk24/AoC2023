
/**
 * @param {string} line
 */
function parseLine(line) {
    const gameIdMatch = /^Game\s(\d+):/.exec(line);
    const id = +gameIdMatch[1];

    let red = 0, blue = 0, green = 0;
    const matches = line
        .substring(gameIdMatch[0].length)
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

    return { id, red, green, blue };
}

/**
 * @param {string} input
 */
function f(input) {
    let total = 0;
    for (const line of input.split('\n')) {
        if (line) {
            const { id, red, green, blue } = parseLine(line);
            if (red <= 12 && green <= 13 && blue <= 14) {
                total += id;
            }
        }
    }
    return total;
}
