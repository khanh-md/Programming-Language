To run the program, I did the following steps:

- Install cabal through ghcup
- Create a ChangeLog.md file
- Modify FORTH.cabal line 50 to:  build-depends:       base >=4.10 && <5

In powershell/terminal, run the following commands inside FORTH directory:
- cabal install
- cabal build
- cabal install hspec --lib
- cabal install flow --lib

I could not run "cabal install hbase", but the program ran without any problem.
I was not able to use the command "cabal run". To run the test cases and HSpecs file:
- runhaskell Main.hs tests/t*.4TH
- runhaskell EvalSpec.hs

The outputs file contain the expected outputs/error messages for the test cases in the tests file.
Implemented features:
- Basic arithmetic operations (+, -, /, ^)
- String operations (STR, CONCAT2, CONCAT3)
- Character output (EMIT, CR)
- Error handling for empty stack, stack underflow and type mismatches

Testcases for error handling might return this line after the expected error output: 
  "CallStack (from HasCallStack): error, called at .\Eval.hs:: in main:Eval"
- This error message is generated when the program uses the HasCallStack feature.
- This will not be included in the output file