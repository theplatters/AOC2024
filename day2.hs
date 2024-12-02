import System.IO  
import Control.Monad

main :: IO ()
main = do
    contents <- readFile "input2.txt" -- Read the file contents
    let allLines = lines contents      -- Split the contents into lines
    let processed = map (map readInt . words) allLines
    let part1 = filter checkList processed
    let part2 = filter checkList2 processed
    print . length $ part1
    print . length $ part2

readInt :: String -> Int
readInt = read

checkList:: [Int] -> Bool
checkList l =  (isOrdered l) || (isOrdered . map Prelude.negate $ l)

isOrdered :: [Int] -> Bool
isOrdered xs = all (\(x, y) -> x < y && y - x < 4) $ zip xs (tail xs)

-- Part2

compositions :: Int -> [a] -> [[a]]
compositions k xs
    | k > length xs = []
    | k <= 0        = [[]]
    | otherwise     = csWithoutHead ++ csWithHead
    where   csWithoutHead = compositions k $ tail xs
            csWithHead    = [ head xs : ys | ys <- compositions (k - 1) $ tail xs ]

checkList2 :: [Int] -> Bool
checkList2 l = any checkList (compositions ((length l) - 1)  l)
