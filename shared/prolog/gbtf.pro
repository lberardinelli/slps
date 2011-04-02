:- module(gbtf,[generateT/2]).

generateT(G,r(G,T))
 :-
   G = g(Rs,Ps),
    ( Rs = [R|_] ->
        true;
        ( Ps = [p(_,R,_)|_] ) ),
    generateT(Ps,n(R),T).

generateT(Ps,n(N),n(P,T))
 :-
    P = p(_,N,X),
    member(P,Ps),
    generateT(Ps,X,T).

generateT(_,true,true).

generateT(_,t(V),t(V)).
