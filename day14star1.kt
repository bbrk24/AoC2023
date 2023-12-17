// Divide each column into sections divided by #s. Count the number of Os and dots in each section.
// Then, the load of each column can be calculated without actually rearranging anything.

data class Section(val rocks: Int, val dots: Int)

fun divideIntoSections(str: String): List<List<Section>> {
    val rows = str.lines()
    val rowLen = rows[0].length
    
    val retval = mutableListOf<List<Section>>()

    for (i in 0..<rowLen) {
        val thisColumn = mutableListOf<Section>()

        var rocks = 0
        var dots = 0
        var lastIsHash = false
        for (row in rows) {
            when (row[i]) {
                'O' -> ++rocks
                '.' -> ++dots
                '#' -> {
                    thisColumn.add(Section(rocks, dots))
                    rocks = 0
                    dots = 0
                }
            }
        }
        thisColumn.add(Section(rocks, dots))

        retval.add(thisColumn)
    }

    return retval
}

fun sectionLoad(sec: Section) = sec.dots * sec.rocks + sec.rocks * (sec.rocks + 1) / 2

fun findLoad(sections: List<Section>): Int {
    var runningLoad = 0
    var rocks = 0
    for (section in sections) {
        runningLoad += rocks
        runningLoad += sectionLoad(section)
        runningLoad += rocks * (section.rocks + section.dots)
        rocks += section.rocks
    }
    return runningLoad
}

fun f(s: String) = divideIntoSections(s).map(::findLoad).sum()
