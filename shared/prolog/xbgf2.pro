:- module(xbgf2,[transformR/3,transformT/3]).
:- use_module('xbgf1.pro').

transformR(Xbgf,r(G1,T1),r(G2,T2))
 :-
    xbgf1:transformG(Xbgf,G1,G2),
    xbgf2:transformT(Xbgf,T1,T2).

transformT(T,T1,T3)
 :-
    T =.. [F|_],
    format('Applying ~q transformation.~n',[F]),
    apply(T,[T1,T2]),
    ytransform(xbgf2:normalizeT_rules,T2,T3),    
    !.

normalizeT_rules(','([]),true).
normalizeT_rules(','([T]),T).
normalizeT_rules('+'(true),true).
normalizeT_rules('*'(true),true).
normalizeT_rules('?'(true),true).
normalizeT_rules(','(Ts1),','(Ts5))
 :-
    append(Ts2,[','(Ts3)|Ts4],Ts1),
    concat([Ts2,Ts3,Ts4],Ts5).
normalizeT_rules(','(Ts1),','(Ts2))
 :-
    append(Ts1a,[true|Ts1b],Ts1),
    append(Ts1a,Ts1b,Ts2).


%
% p([l(add)], f, n(p))
%
% Add a production to an existing definition
%


%
% p([l(caseAllDown)], f, true)
% p([l(caseAllUp)], f, true)
% p([l(caseFirstDown)], f, true)
% p([l(caseFirstUp)], f, true)
%
% Normalize case for all sorts of symbols
%

caseAllDown(G1,G2) :- case(all,down,G1,G2).
caseAllUp(G1,G2) :- case(all,up,G1,G2).
caseFirstDown(G1,G2) :- case(first,down,G1,G2).
caseFirstUp(G1,G2) :- case(first,up,G1,G2).

case(Q,UD,T1,T2) 
 :-
    transform(xbgf2:case_rule(Q,UD),T1,T2).

case_rule(Q,UD,g(Rs1,Ps),g(Rs2,Ps)) :- maplist(xbgf1:doCase(Q,UD),Rs1,Rs2).
case_rule(Q,UD,p(As,N1,X),p(As,N2,X)) :- xbgf1:doCase(Q,UD,N1,N2).
case_rule(Q,UD,n(N1),n(N2)) :- xbgf1:doCase(Q,UD,N1,N2).
case_rule(Q,UD,l(L1),l(L2)) :- xbgf1:doCase(Q,UD,L1,L2).
case_rule(Q,UD,s(S1,X),s(S2,X)) :- xbgf1:doCase(Q,UD,S1,S2).


%
% p([l(define)], f, +n(p))
%
% Define a nonterminal
%

define(_,T1,T1)
 :-
    !.


%
% p([l(designate)], f, n(p))
%
% Label a production
%

designate(P1,T1,T2)
 :-
    transform(xbgf2:designate_rule(P1),T1,T2).

designate_rule(P1,n(P2,T),n(P1,T))
 :-
    P1 = p([l(_)],N,X),
    P2 = p([],N,X).


%
% p([l(eliminate)], f, n(n))
%
% Eliminate a defined, otherwise unused nonterminal
%


%
% p([l(extract)], f, n(p))
%
% Extract a nonterminal definition
%

extract(_,T1,T1)
 :-
    !.


%
% p([l(fold)], f, n(p))
%
% Fold an expression to its defining nonterminal
%

fold(_,T1,T1)
 :-
    !.


%
% p([l(horizontal)], f, n(n))
%
% Turn multiple productions into choice
%


%
% p([l(id)], f, true)
%
% Identity
%

id(T1,T1).


%
% p([l(inline)], f, n(n))
%
% Inline a nonterminal definition (and eliminate it)
%

inline(_,T1,T1)
 :- 
    !.
    

%
% p([l(introduce)], f, +n(p))
%
% Add a definition for a fresh nonterminal
%

introduce(_,T1,T1)
 :-
    !.


%
% p([l(lassoc)], f, n(p))
%
% Interpret separator list left-associatively
%

lassoc(P1,T1,T2)
 :-
    transform(xbgf2:lassoc_rule(P1),T1,T2).

lassoc_rule(P1,n(P2,','([T1,'*'(Ts)])),T2)
 :-
    P1 = p(As,N,X1),
    P2 = p(As,N,X2),
    xbgf1:lassoc_rule(N,X1,X2),
    lassoc_strategy(P2,Ts,T1,T2).

lassoc_strategy(_,[],T,T).
lassoc_strategy(P,[','([Ta,Tb])|Ts],T1,T2)
 :-
    lassoc_strategy(P,Ts,n(P,','([T1,Ta,Tb])),T2).


%
% p([l(modulo)], f, n(p))
%
% Equality modulo selectors
%

modulo(P1,T1,T2)
 :-
    transform(xbgf2:modulo_rule(P1),T1,T2).

modulo_rule(P2,n(P1,T1),n(P2,T2))
 :-
    P1 = p(As,N,X1),
    P2 = p(As,N,X2),
    modulo_strategy(X1,X2,T1,T2).

modulo_strategy(true,true,true,true).

modulo_strategy(t(T),t(T),t(T),t(T)).

modulo_strategy(n(N),n(N),n(P,T),n(P,T))
 :-
    P = p(_,N,_).

modulo_strategy(X1,s(S,X2),T1,s(S,T2))
 :-
    modulo_strategy(X1,X2,T1,T2).

modulo_strategy(s(S,X1),X2,s(S,T1),T2)
 :-
    modulo_strategy(X1,X2,T1,T2).

modulo_strategy(','(Xs1),','(Xs2),','(Ts1),','(Ts2))
 :- 
    maplist(xbgf2:modulo_strategy,Xs1,Xs2,Ts1,Ts2).

modulo_strategy(';'(Xs1),';'(Xs2),';'(X1,T1),';'(X2,T2))
 :-
    maplist(xbgf1:modulo_strategy,Xs1,Xs2),
    append(Xs1a,[X1|_],Xs1),
    append(Xs2a,[X2|_],Xs2),
    length(Xs1a,Len),
    length(Xs2a,Len),
    modulo_strategy(X1,X2,T1,T2).

modulo_strategy('*'(X1),'*'(X2),'*'(Ts1),'*'(Ts2))
 :-
    maplist(xbgf2:modulo_strategy(X1,X2),Ts1,Ts2).

modulo_strategy('+'(X1),'+'(X2),'+'(Ts1),'+'(Ts2))
 :-
    maplist(xbgf2:modulo_strategy(X1,X2),Ts1,Ts2).

modulo_strategy('?'(X1),'?'(X2),'?'(Ts1),'?'(Ts2))
 :-
    maplist(xbgf2:modulo_strategy(X1,X2),Ts1,Ts2).


%
% p([l(permute)], f, n(p))
%
% Permute the body of a production
%

permute(_,T1,T1)
 :- 
    !.


%
% p([l(project)], f, n(p))
%
% Apply projection to the body of a production
%

%
% p([l(prune)], f, n(n))
%
% Prune nonterminals
% (Assume epsilon as missing definition)
%

prune(_,T1,T1)
 :-
    !.
    

% p([l(relax)], f, n(p))

% p([l(relabel)], f, n(p))


%
% p([l(remove)], f, n(p))
%
% Remove a production
%

remove(_,T1,T1)
 :- 
    !.   


%
% p([l(renameL)], f, ','([n(l), n(l)]))
% p([l(renameN)], f, ','([n(n), n(n)]))
% p([l(renameS)], f, ','([?(n(l)), n(s), n(s)]))
% p([l(renameT)], f, ','([n(t), n(t)]))
%
% Rename labels, nonterminals, selectors, and terminals
%

renameL((L1,L2),T1,T2)
 :-
    renameL(L1,L2,T1,T2).

renameL(L1,L2,T1,T2)
 :-
    transform(xbgf1:renameL_rule(L1,L2),T1,T2).

renameN((N1,N2),T1,T2)
 :-
    renameN(N1,N2,T1,T2).

renameN(N1,N2,T1,T2)
 :-
    transform(xbgf1:renameN_rules(N1,N2),T1,T2).

renameS((S1,S2),T1,T2)
 :-
    renameS([],S1,S2,T1,T2).

renameS([],S1,S2,T1,T2)
 :-
    transform(xbgf1:renameS_rule(S1,S2),T1,T2).

renameS([L],S1,S2,T1,T2)
 :-
    transform(xbgf2:renameS_rule(L,S1,S2),T1,T2).

renameS_rule(L,S1,S2,n(P1,T1),n(P2,T2))
 :-
    P1 = p([l(L)],_,_),
    transform(xbgf1:renameS_rule(S1,S2),P1,P2),
    transformWhile(
      xbgf1:renameS_rule(S1,S2),
      xbgf2:renameS_scope,
      T1, 
      T2).

renameS_scope(T) :- \+ T = n(_,_).


%
% p([l(reroot)], f, *(n(n)))
%
% Assign new roots to the grammar
%

reroot(_,T1,T1)
 :-
    !.


%
% p([l(restrict)], f, n(p))
%
% Restrict the grammar by expression replacement
%

restrict(_,T1,T1)
 :-
    !.


% p([l(sequence)], f, *(n(f)))

sequence(Ts,T1,T2)
 :-
    accum(xbgf2:transformT,Ts,T1,T2).


%
% p([l(skip)], f, n(p))
%
% Skip a production
%

skip(_,T1,T1)
 :- 
    !.


%
% p([l(stripL)], f, n(l))
% p([l(stripLs)], f, true)
% p([l(stripS)], f, n(s))
% p([l(stripSs)], f, true)
% p([l(stripT)], f, n(t))
% p([l(stripTs)], f, true)
%
% Strip labels, selectors, and terminals
%

stripL(_,T1,T1)
 :-
    !.

stripLs(T1,T1)
 :-
    !.

stripS(_,T1,T1)
 :-
    !.

stripSs(T1,T2)
 :-
    transform(xbgf2:stripS_rule,T1,T2).

stripTs(T1,T1)
 :-
    !.

stripT(_,T1,T1) 
 :-
    !.

stripS_rule(s(_,X),X).


%
% p([l(unchain)], f, n(n))
%
% Unchain a nonterminal -- a restricted unfold
%

unchain(N,T1,T2)
 :-
    transform(xbgf2:unchain_rule(N),T1,T2).

unchain_rule(
    N1,
    n(p(As1,N2,n(N1)),n(p(_,N1,X),T)),
    n(p(As2,N2,X),T))
 :-
    unchain_label(As1,N1,As2).

unchain_label([],N,[l(N)]).
unchain_label([l(L)],_,[l(L)]).


%
% p([l(undefine)], f, n(n))
%
% Undefine a nonterminal, i.e., remove all productions
%

undefine(N,T,T)
 :-
    visit(xbgf2:undefine_rule(N),T).

undefine_rule(N1,n(P,_))
 :-
    P = p(_,N2,_),
    require(
      ( \+ N1 == N2 ),
      'Undefined nonterminal used.',
      [N1]).


%
% p([l(unfold)], f, n(p))
%
% Unfold a nonterminal in a production
%

unfold(_,T1,T1)
 :-
    !.


%
% p([l(unite)], f, ','([n(n), n(n)]))
%
% Confusing renaming, also called "unification"
%

unite(_,_,T1,T1)
 :-
    !.


%
% p([l(verticalL)], f, n(l))
% p([l(verticalN)], f, n(n))
%
% Turn choices into definitions of multiple productions
%

verticalL(L,T1,T2)
 :-
    transform(xbgf2:verticalL_rule(L),T1,T2).

verticalL_rule(
  L,
  n(p([l(L)],N,X),T1),
  n(P,T2)
)
 :-
    vertical(N,X,P,T1,T2).

verticalN(N,T1,T2)
 :-
    transform(xbgf2:verticalN_rule(N),T1,T2).

verticalN_rule(
  N,
  n(p(_,N,X),T1),
  n(P,T2)
)
 :-
    vertical(N,X,P,T1,T2).
  
vertical(N,X1,P,T1,T3)
 :-
    findall(X2,xbgf1:vertical_strategy(X1,X2),Xs),
    member(X3,Xs),
    vertical_strategy(X3,T1,T2),
    vertical_rules(N,X3,P,T2,T3).

vertical_rules(N,s(S,X),p([l(S)],N,X),s(S,T),T).
vertical_rules(N,X,p([],N,X),T,T) :- \+ X = s(_,_).


vertical_strategy(true,true,true)
 :-
    !.

vertical_strategy(a,a(Ns),a(Ns))
 :-
    !.

vertical_strategy(t(V),t(V),t(V))
 :-
    !.

vertical_strategy(v(string),v(string(V)),v(string(V)))
 :-
    !.

vertical_strategy(v(int),v(int(V)),v(string(V)))
 :-
    !.

vertical_strategy(n(N),n(P,T),n(P,T))
 :-
    P = p(_,N,_),
    !.

vertical_strategy('*'(X1),'*'(Ts1),'*'(Ts2))
 :-
    maplist(xbgf2:vertical_strategy(X1),Ts1,Ts2),
    !.

vertical_strategy('+'(X1),'+'(Ts1),'+'(Ts2))
 :-
    maplist(xbgf2:vertical_strategy(X1),Ts1,Ts2),
    !.

vertical_strategy('?'(X1),'?'(Ts1),'?'(Ts2))
 :-
    maplist(xbgf2:vertical_strategy(X1),Ts1,Ts2),
    !.

vertical_strategy(','(Xs),','(Ts1),','(Ts2))
 :-
    maplist(xbgf2:vertical_strategy,Xs,Ts1,Ts2).

vertical_strategy(X,';'(_,T1),T2)
 :-
    vertical_strategy(X,T1,T2).

vertical_strategy(s(S,X),s(S,T1),s(S,T2))
 :-
    vertical_strategy(X,T1,T2).
