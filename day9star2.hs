-- Adapted from https://codegolf.stackexchange.com/a/47011/106545
listDifference :: (Num a) => [a] -> [a]
listDifference = zipWith (-) =<< tail

-- Taken from https://stackoverflow.com/q/6121256/6253337
allTheSame :: (Eq a) => [a] -> Bool
allTheSame xs = and $ map (== head xs) (tail xs)

-- This point on is my own work
postdiction :: [Int] -> Int
postdiction xs = (head xs) - if allTheSame xs
    then 0
    else postdiction $ listDifference xs

processLine :: String -> Int
processLine arg = postdiction $ map read (words arg)

f :: String -> Int
f arg = sum $ map processLine (lines arg)
