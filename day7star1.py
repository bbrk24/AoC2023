from enum import Enum
from functools import cmp_to_key

class HandType(Enum):
    FIVE_OF_A_KIND = 0
    FOUR_OF_A_KIND = 1
    FULL_HOUSE = 2
    THREE_OF_A_KIND = 3
    TWO_PAIR = 4
    ONE_PAIR = 5
    HIGH_CARD = 6

def card_value(label: str):
    if label.isdigit():
        return int(label)
    match label:
        case 'T':
            return 10
        case 'J':
            return 11
        case 'Q':
            return 12
        case 'K':
            return 13
        case 'A':
            return 14

class Hand:
    def __init__(self, s: str):
        self.string = s
    
    def type(self) -> HandType:
        str_set = set(self.string)
        match len(str_set):
            case 1:
                return HandType.FIVE_OF_A_KIND
            case 2:
                for char in str_set:
                    if self.string.count(char) > 3:
                        return HandType.FOUR_OF_A_KIND
                return HandType.FULL_HOUSE
            case 3:
                for char in str_set:
                    if self.string.count(char) > 2:
                        return HandType.THREE_OF_A_KIND
                return HandType.TWO_PAIR
            case 4:
                return HandType.ONE_PAIR
            case 5:
                return HandType.HIGH_CARD
    
    def compare(self, other: "Hand") -> int:
        if self is other:
            return 0
        
        own_type = self.type()
        other_type = other.type()
        if own_type != other_type:
            return other_type.value - own_type.value
        
        for own_card, other_card in zip(self.string, other.string):
            if own_card != other_card:
                return card_value(own_card) - card_value(other_card)
        
        return 0

def f(s: str):
    lines = s.strip().split('\n')
    cols = map(str.split, lines)
    hands_and_bids = [(Hand(l[0]), int(l[1])) for l in cols]
    hands_and_bids.sort(key=cmp_to_key(lambda t1, t2: t1[0].compare(t2[0])))

    total = 0
    for i, (_, bid) in enumerate(hands_and_bids):
        total += bid * (i + 1)
    return total
