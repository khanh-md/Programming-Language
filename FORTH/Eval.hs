module Eval where
-- This file contains definitions for functions and operators

import Val
import Data.Char (chr)

-- main evaluation function for operators and 
-- built-in FORTH functions with no output
-- takes a string and a stack and returns the stack
-- resulting from evaluation of the function
eval :: String -> [Val] -> [Val]

-- Addition
eval "+" (Integer x : Integer y : tl) = Integer (y + x) : tl
eval "+" (x : y : tl) = Real (toFloat y + toFloat x) : tl
eval "+" _ = error "Stack underflow"

-- Subtraction
eval "-" (Integer x : Integer y : tl) = Integer (y - x) : tl
eval "-" (x : y : tl) = Real (toFloat y - toFloat x) : tl
eval "-" _ = error "Stack underflow"

-- Division
eval "/" (Integer 0 : _ : _) = error "Division by zero"
eval "/" (Integer x : Integer y : tl) = Real (fromIntegral y / fromIntegral x) : tl
eval "/" (x : y : tl) = 
    if toFloat x == 0 
    then error "Division by zero"
    else Real (toFloat y / toFloat x) : tl
eval "/" _ = error "Stack underflow"

-- Power
eval "^" (Integer x : Integer y : tl) = Integer (y ^ x) : tl
eval "^" (x : y : tl) = Real (toFloat y ** toFloat x) : tl
eval "^" _ = error "Stack underflow"

-- Multiplication
-- if arguments are integers, keep result as integer
eval "*" (Integer x: Integer y:tl) = Integer (x*y) : tl
-- if any argument is float, make result a float
eval "*" (x:y:tl) = (Real $ toFloat x * toFloat y) : tl 
-- any remaining cases are stacks too short
eval "*" _ = error("Stack underflow")


-- Duplicate the element at the top of the stack
eval "DUP" (x:tl) = (x:x:tl)
eval "DUP" [] = error("Stack underflow")

eval "STR" (Integer n:tl) = Id (show n) : tl
eval "STR" (Real f:tl) = Id (show f) : tl
eval "STR" (Id s:tl) = Id (show s) : tl
eval "STR" [] = error "Stack underflow"

eval "CONCAT2" (Id s2 : Id s1 : tl) = Id (s1 ++ s2) : tl
eval "CONCAT2" _ = error "CONCAT2 requires two strings"

eval "CONCAT3" (Id s3 : Id s2 : Id s1 : tl) = Id (s1 ++ s2 ++ s3) : tl
eval "CONCAT3" _ = error "CONCAT3 requires three strings"

-- this must be the last rule
-- it assumes that no match is made and preserves the string as argument
eval s l = Id s : l 


-- variant of eval with output
-- state is a stack and string pair
evalOut :: String -> ([Val], String) -> ([Val], String) 
-- print element at the top of the stack
evalOut "." (Id x:tl, out) = (tl, out ++ x)
evalOut "." (Integer i:tl, out) = (tl, out ++ (show i))
evalOut "." (Real x:tl, out) = (tl, out ++ (show x))

evalOut "EMIT" (Integer n:tl, out) = (tl, out ++ [chr n])
evalOut "EMIT" _ = error "EMIT requires an integer"

evalOut "CR" (stack, out) = (stack, out ++ "\n")

evalOut "." ([], _) = error "Stack underflow"

-- this has to be the last case
-- if no special case, ask eval to deal with it and propagate output
evalOut op (stack, out) = (eval op stack, out)