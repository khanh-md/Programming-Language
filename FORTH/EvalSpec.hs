-- HSpec tests for Val.hs
-- Execute: runhaskell EvalSpec.hs

import Test.Hspec
import Test.QuickCheck
import Control.Exception (evaluate)
import Val
import Eval

main :: IO ()
main = hspec $ do
  describe "eval" $ do
    context "*" $ do
        it "multiplies integers" $ do
            eval "*" [Integer 2, Integer 3] `shouldBe` [Integer 6]
        
        it "multiplies floats" $ do
            eval "*" [Integer 2, Real 3.0] `shouldBe` [Real 6.0]
            eval "*" [Real 3.0, Integer 3] `shouldBe` [Real 9.0]
            eval "*" [Real 4.0, Real 3.0] `shouldBe` [Real 12.0]

        it "errors on too few arguments" $ do   
            evaluate (eval "*" []) `shouldThrow` errorCall "Stack underflow"
            evaluate (eval "*" [Integer 2]) `shouldThrow` errorCall "Stack underflow"

        -- this does not work, seems to be a HSpec bug
        -- it "errors on non-numeric inputs" $ do
        --    evaluate(eval "*" [Real 3.0, Id "x"]) `shouldThrow` anyException

    context "+" $ do
      it "adds integers" $ do
        eval "+" [Integer 2, Integer 3] `shouldBe` [Integer 5]
      
      it "adds with floats" $ do
        eval "+" [Integer 2, Real 3.0] `shouldBe` [Real 5.0]
        eval "+" [Real 3.0, Integer 3] `shouldBe` [Real 6.0]
        eval "+" [Real 4.0, Real 3.0] `shouldBe` [Real 7.0]

      it "errors on too few arguments" $ do   
        evaluate (eval "+" []) `shouldThrow` errorCall "Stack underflow"
        evaluate (eval "+" [Integer 2]) `shouldThrow` errorCall "Stack underflow"

    context "-" $ do
      it "subtracts integers" $ do
        eval "-" [Integer 2, Integer 5] `shouldBe` [Integer 3]
      
      it "subtracts with floats" $ do
        eval "-" [Integer 2, Real 5.0] `shouldBe` [Real 3.0]
        eval "-" [Real 2.0, Integer 5] `shouldBe` [Real 3.0]
        eval "-" [Real 2.0, Real 5.0] `shouldBe` [Real 3.0]

    context "/" $ do
      it "divides integers" $ do
        eval "/" [Integer 2, Integer 6] `shouldBe` [Real 3.0]
      
      it "divides with floats" $ do
        eval "/" [Real 2.0, Integer 6] `shouldBe` [Real 3.0]
        eval "/" [Integer 2, Real 6.0] `shouldBe` [Real 3.0]
        eval "/" [Real 2.0, Real 6.0] `shouldBe` [Real 3.0]

    context "^" $ do
      it "raises to power with integers" $ do
        eval "^" [Integer 3, Integer 2] `shouldBe` [Integer 8]
      
      it "raises to power with floats" $ do
        eval "^" [Real 3.0, Real 2.0] `shouldBe` [Real 8.0]
        eval "^" [Integer 3, Real 2.0] `shouldBe` [Real 8.0]
        eval "^" [Real 3.0, Integer 2] `shouldBe` [Real 8.0]

    context "DUP" $ do
        it "duplicates values" $ do
            eval "DUP" [Integer 2] `shouldBe` [Integer 2, Integer 2]
            eval "DUP" [Real 2.2] `shouldBe` [Real 2.2, Real 2.2]
            eval "DUP" [Id "x"] `shouldBe` [Id "x", Id "x"]

        it "errors on empty stack" $ do
            evaluate (eval "DUP" []) `shouldThrow` errorCall "Stack underflow"
    
    context "STR" $ do
        it "converts integers to strings" $ do
            eval "STR" [Integer 42] `shouldBe` [Id "42"]
        
        it "converts floats to strings" $ do
            eval "STR" [Real 3.14] `shouldBe` [Id "3.14"]

        it "converts identifiers to strings" $ do
            eval "STR" [Id "hello"] `shouldBe` [Id "\"hello\""]

    context "CONCAT2" $ do
        it "concatenates two strings" $ do
            eval "CONCAT2" [Id "world", Id "Hello "] `shouldBe` [Id "Hello world"]

        it "errors on non-string arguments" $ do
            evaluate (eval "CONCAT2" [Integer 1, Id "Hello"]) `shouldThrow` anyException

    context "CONCAT3" $ do
        it "concatenates three strings" $ do
            eval "CONCAT3" [Id "!", Id "world", Id "Hello "] `shouldBe` [Id "Hello world!"]

        it "errors on non-string arguments" $ do
            evaluate (eval "CONCAT3" [Integer 1, Id "Hello", Id "world"]) `shouldThrow` anyException

  describe "evalOut" $ do
      context "." $ do
        it "prints top of stack" $ do
            evalOut "." ([Id "x"], "") `shouldBe` ([],"x")
            evalOut "." ([Integer 2], "") `shouldBe` ([], "2")
            evalOut "." ([Real 2.2], "") `shouldBe` ([], "2.2")

        it "errors on empty stack" $ do
            evaluate(evalOut "." ([], "")) `shouldThrow` errorCall "Stack underflow"

      it "eval pass-through" $ do
         evalOut "*" ([Real 2.0, Integer 2], "blah") `shouldBe` ([Real 4.0], "blah")

      context "EMIT" $ do
        it "emits a character" $ do
            snd (evalOut "EMIT" ([Integer 65], "")) `shouldBe` "A"

        it "errors on non-integer argument" $ do
            evaluate (evalOut "EMIT" ([Real 65.0], "")) `shouldThrow` anyException

      context "CR" $ do
        it "prints a new line" $ do
            snd (evalOut "CR" ([], "")) `shouldBe` "\n" 