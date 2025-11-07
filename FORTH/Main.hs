module Main where

-- Running: runhaskell Main.hs path_to_test_file

import Interpret
import System.Environment

main :: IO ()
main = do
    args <- getArgs
    case args of
        [fileName] -> do
            contents <- readFile fileName
            let (stack, output) = interpret contents
            putStrLn output
            if not (null stack)
                then do
                    putStrLn $ "Stack is not empty at the end of execution: " ++ show stack
                else return()
        _ -> putStrLn "Usage: runhaskell Main.hs <filename>"

