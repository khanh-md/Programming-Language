/* match functions by unifying with arguments 
    and infering the result
*/
:- dynamic gvar/2.
:- dynamic lvar/2.

typeExp(Fct, T):-
    \+ var(Fct), /* make sure Fct is not a variable */ 
    \+ atom(Fct), /* or an atom */
    functor(Fct, Fname, _Nargs), /* ensure we have a functor */
    !, /* if we make it here we do not try anything else */
    Fct =.. [Fname|Args], /* get list of arguments */
    append(Args, [T], FType), /* make it loook like a function signature */
    functionType(Fname, TArgs), /* get type of arguments from definition */
    typeExpList(FType, TArgs). /* recurisvely match types */

/* propagate types */
typeExp(T, T).

/* list version to allow function mathine */
typeExpList([], []).
typeExpList([Hin|Tin], [Hout|Tout]):-
    typeExp(Hin, Hout), /* type infer the head */
    typeExpList(Tin, Tout). /* recurse */

/* TODO: add statements types and their type checking */
/* global variable definition
    Example:
        gvLet(v, T, int) ~ let v = 3;
 */
typeStatement(gvLet(Name, T, Code), unit):-
    atom(Name), 
    typeCode([Code], T), 
    bType(T), 
    asserta(gvar(Name, T)). 

% Global variable reference
typeStatement(gvar(VarName, VarType), VarType) :-
    gvar(VarName, VarType).             % Lookup global variable type

% Local variable reference
typeStatement(lvar(VarName, VarType), VarType) :-
    lvar(VarName, VarType).             % Lookup local variable type

% Expression statement
typeStatement(Expr, ResultType) :-
    typeExp(Expr, ResultType),           % Type infer for expression
    bType(ResultType).                 

% letIn statement
typeStatement(letIn(VarName, VarType, CodeBody, FuncBody), unit) :-
    atom(VarName),
    typeCode([CodeBody], VarType),   % Type inference for the body
    bType(VarType),                   % Ensure VarType is valid
    asserta(lvar(VarName, VarType)),  % Add local variable 
    typeCode(FuncBody, _),            % Type infer
    retract(lvar(VarName, VarType)). 

% Global function definition
typeStatement(gfLet(FuncName, ArgsList, RetType, FuncBody), RetType) :-
    atom(FuncName),
    typeCode(FuncBody, RetType),          % Type infer
    is_list(ArgsList),                    % Ensure arguments are in a list
    append(ArgsList, [RetType], FullSig), % Append return type to function signature
    asserta(gvar(FuncName, FullSig)).     % Store global function definition

% If-else statement
typeStatement(if(Condition, TrueBranch, FalseBranch), ResultType) :-
    typeExp(Condition, bool),            % must be of type bool
    typeCode(TrueBranch, ResultType),    % Type infer for true branch
    typeCode(FalseBranch, ResultType),   % Type infer for false branch
    bType(ResultType).                   

% For loop statement
typeStatement(for(Assignment, Condition, LoopBody), UnitType) :-
    typeExp(Assignment, int),            % must be of type int
    typeExp(Condition, bool),            % must be of type bool
    typeCode(LoopBody, _),               % Type infer for loop body
    typeExp(UnitType, unit).             % Ensure unit type for loop

/* Code is simply a list of statements. The type is 
    the type of the last statement 
*/
typeCode([S], T):-typeStatement(S, T).
typeCode([S, S2|Code], T):-
    typeStatement(S,_T),
    typeCode([S2|Code], T).
typeCode([], T):- bType(T).


/* top level function */
infer(Code, T) :-
    is_list(Code),
    deleteGVars(),
    typeCode(Code, T).
/* Basic types
    TODO: add more types if needed
 */
bType(bool).
bType(int).
bType(float).
bType(string).
bType(unit). /* unit type for things that are not expressions */
/*  functions type.
    The type is a list, the last element is the return type
    E.g. add: int->int->int is represented as [int, int, int]
    and can be called as add(1,2)->3
 */
bType([H]):- bType(H).
bType([H|T]):- bType(H), bType(T).


/*
    TODO: as you encounter global variable definitions
    or global functions add their definitions to 
    the database using:
        asserta( gvar(Name, Type) )
    To check the types as you encounter them in the code
    use:
        gvar(Name, Type) with the Name bound to the name.
    Type will be bound to the global type
    Examples:
        g

    Call the predicate deleveGVars() to delete all global 
    variables. Best wy to do this is in your top predicate
*/

deleteGVars :-
    retractall(gvar),
    retractall(lvar),
    asserta((gvar(_, _) :- false)),
    asserta((lvar(_, _) :- false)).

/*  builtin functions
    Each definition specifies the name and the 
    type as a function type

    TODO: add more functions
*/

fType(iplus, [int,int,int]).    % Addition
fType(isub, [int, int, int]).   % Subtraction
fType(imul, [int, int, int]).   % Multiplication
fType(idiv, [int, int, int]).   % Division
fType(imod, [int, int, int]).   % Modulo

% Float operations
fType(fplus, [float, float, float]).
fType(fsub, [float, float, float]).
fType(fmul, [float, float, float]).
fType(fdiv, [float, float, float]).

% Integer comparisons
fType(eq_int,  [int, int, bool]).   % ==
fType(neq_int, [int, int, bool]).   % !=
fType(lt_int,  [int, int, bool]).   % <
fType(gt_int,  [int, int, bool]).   % >

% Float comparisons
fType(eq_float,  [float, float, bool]).
fType(neq_float, [float, float, bool]).
fType(lt_float,  [float, float, bool]).

fType(fToInt, [float,int]).
fType(iToFloat, [int,float]).
fType(print, [_X, unit]). /* simple print */

/* Find function signature
   A function is either buld in using fType or
   added as a user definition with gvar(fct, List)
*/

% Check the user defined functions first
functionType(Name, Args):-
    gvar(Name, Args),
    is_list(Args), !. % make sure we have a function not a simple variable 

% Check first built in functions
functionType(Name, Args) :-
    fType(Name, Args), !. % make deterministic

% This gets wiped out but we have it here to make the linter happy
gvar(_, _) :- false().
