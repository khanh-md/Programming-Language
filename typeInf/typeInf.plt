:- begin_tests(typeInf).
:- include(typeInf). 

/* Test 1: Integer addition */
test(addInt, [nondet]) :-
    infer([iplus(X, Y)], T),
    assertion(T == int),
    assertion(X == int),
    assertion(Y == int).

/* Test 2: Float subtraction */
test(subFloat, [nondet]) :-
    infer([fsub(X, Y)], T),
    assertion(T == float),
    assertion(X == float),
    assertion(Y == float).

/* Test 3: Nested arithmetic */
test(nestedArithmetic, [nondet]) :-
    infer([imul(int, iplus(int, T))], T1),
    assertion(T == int),
    assertion(T1 == int).

/* Test 4: Integer modulo */
test(modInt, [nondet]) :-
    infer([imod(X, Y)], T),
    assertion(T == int),
    assertion(X == int),
    assertion(Y == int).

/* Test 5: Float division */
test(divFloat, [nondet]) :-
    infer([fdiv(X, Y)], T),
    assertion(T == float),
    assertion(X == float),
    assertion(Y == float).

/* Test 6: Integer equality */
test(eqInt, [nondet]) :-
    infer([eq_int(X, Y)], T),
    assertion(T == bool),
    assertion(X == int),
    assertion(Y == int).

/* Test 7: Integer inequality */
test(neqInt, [nondet]) :-
    infer([neq_int(X, Y)], T),
    assertion(T == bool),
    assertion(X == int),
    assertion(Y == int).

/* Test 8: Integer less than */
test(ltInt, [nondet]) :-
    infer([lt_int(X, Y)], T),
    assertion(T == bool),
    assertion(X == int),
    assertion(Y == int).

/* Test 9: Integer greater than */
test(gtInt, [nondet]) :-
    infer([gt_int(X, Y)], T),
    assertion(T == bool),
    assertion(X == int),
    assertion(Y == int).

/* Test 10: Float equality */
test(eqFloat, [nondet]) :-
    infer([eq_float(X, Y)], T),
    assertion(T == bool),
    assertion(X == float),
    assertion(Y == float).

/* Test 11: Float inequality */
test(neqFloat, [nondet]) :-
    infer([neq_float(X, Y)], T),
    assertion(T == bool),
    assertion(X == float),
    assertion(Y == float).

/* Test 12: Float less than */
test(ltFloat, [nondet]) :-
    infer([lt_float(X, Y)], T),
    assertion(T == bool),
    assertion(X == float),
    assertion(Y == float).

/* Test 13: Global variable definition and usage */
test(globalVarAndUsage, [nondet]) :-
    infer([gvLet(x, T, float), gvar(x, T2), fplus(T4, fplus(T3, fplus(float, T2)))], _),
    assertion(T == float),
    assertion(T2 == float),
    assertion(T3 == float),
    assertion(T4 == float),
    gvar(x, float).

/* Test 14: If statement */
test(ifStatement, [nondet]) :-
    infer([if(lt_float(float, float), [int, float, int], [int, int])], T),
    assertion(T == int).

/* Test 15: Nested if statement */
test(nestedIfStatement, [nondet]) :-
    infer([if(lt_float(float, float), [int, float, int], [if(lt_float(float, float), [int, float, int], [int, int])])], T),
    assertion(T == int).

/* Test 16: For loop */
test(forLoop, [nondet]) :-
    infer([for(int, lt_int(X, Y), [int, int, string, int])], T),
    assertion(T == unit),
    assertion(X == int),
    assertion(Y == int).

/* Test 17: Global function definition */
test(globalFunctionDef, [nondet]) :-
    infer([gfLet(add, [int, int], T, [iplus(X, Y)])], T1),
    assertion(T == int),
    assertion(T1 == int),
    assertion(X == int),
    assertion(Y == int),
    gvar(add, [int, int, int]).

/* Test 18: Let-in expression */
test(letInExpression, [nondet]) :-
    infer([letIn(x, T, float, [iplus(X, Y)])], unit),
    assertion(T == float),
    assertion(X == int),
    assertion(Y == int),
    \+ lvar(x, _).

/* Test 19: Type conversion */
test(typeConversion, [nondet]) :-
    infer([fToInt(X)], T),
    assertion(T == int),
    assertion(X == float).

/* Test 20: Function application */
test(functionTest, [nondet]) :-
    infer([gvLet(y, T1, int), gfLet(multiply, [int, int], T, [int, gvar(y, T2)])], _),
    assertion(T1 == int),
    assertion(T2 == int),
    assertion(T == int),
    gvar(y, int),
    gvar(multiply, [int, int, int]).


/* Test 21: Multiple statements */
test(multipleStatements, [nondet]) :-
    infer([gvLet(a, T1, int), gvLet(b, T2, float), gvLet(c, T3, string), gvLet(d, T4, bool), gvLet(e, T5, unit)], _),
    assertion(T1 == int),
    assertion(T2 == float),
    assertion(T3 == string),
    assertion(T4 == bool),
    assertion(T5 == unit),
    gvar(a, int),
    gvar(b, float),
    gvar(c, string),
    gvar(d, bool),
    gvar(e, unit).

/* Test 22: Empty code block */
test(emptyCodeBlock, [nondet]) :-
    infer([], T),
    assertion(bType(T)).

/* Test 23: Print statement */
test(printStatement, [nondet]) :-
    infer([print(int)], T),
    assertion(T == unit).

:-end_tests(typeInf).
