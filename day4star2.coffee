cards = [null]

parseRow = (str) ->
  [str, cardNo, winningStr, selectedStr] = /^Card\s+(\d+):((?:\s+\d+)+)\s\|((?:\s+\d+)+)$/.exec str
  winning = winningStr.split /\s+/g
    .filter Boolean
    .map Number
  selected = selectedStr.split /\s+/g
    .filter Boolean
    .map Number
  cards[cardNo] = { cardNo: +cardNo, winning, selected, count: 1 }

processRow = (obj) ->
  numMatches = obj.selected
    .filter (x) => x in obj.winning
    .length
  if numMatches isnt 0
    for i in [1..numMatches]
      cards[i + obj.cardNo].count += obj.count

f = (str) ->
  arr = str.split '\n'
    .map parseRow
  arr.forEach processRow
  arr.reduce (a, obj) ->
    a + obj.count
  , 0
