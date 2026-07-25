:- use_module(library(clpfd)).
:- [tests].
:- [mytests].

% 0 is no snake
% 1 is head/tail of snake
% 2 is body of snake
% -1 is unknown

%SNAKE
snake(RowHints, ColHints, Grid, Solution) :-
    copyGrid(Grid, Solution),

    correctRowHints(RowHints, Solution),
    correctColHints(ColHints, Solution),

    nonTouching(Solution),
    countNeighbours(Solution),
    twoHeads(Solution),

    % makes a list of lists a single list
    append(Solution, Variables),
    % in the clpfd library
    labeling([ffc], Variables),

    snakeConnected(Solution).

%copyGrid creates the variables.
copyGrid([],[]).
copyGrid([R|Rows], [NR|NewRows]) :-
    copyRow(R, NR),
    copyGrid(Rows, NewRows).

copyRow([],[]).
copyRow([-1|Row], [X|Sol]) :-
    X in 0..2,
    copyRow(Row,Sol).
copyRow([Cell|Row], [Cell|Sol]) :-
    Cell =\= -1,
    copyRow(Row,Sol).

%correctRowHints uses the rowCounter to check the hints
correctRowHints([],[]).
correctRowHints([-1|Hints], [_|Rows]) :-
    correctRowHints(Hints,Rows).
correctRowHints([H|Hints],[Row|Rows]) :-
    H #>= 0,
    rowCounter(Row, H),
    correctRowHints(Hints, Rows).

%rowCounter
cell_snake(Cell, B) :-
    B in 0..1,
    B #<==> (Cell #> 0).

rowCounter(Row, Hint) :-
    maplist(cell_snake, Row, Bs),
    sum(Bs, #=, Hint).

%correctColHints uses the transpose and correctRowHints
correctColHints(ColHints, Grid) :-
    transpose(Grid, TGrid),
    correctRowHints(ColHints, TGrid).

%nonTouching
% Slides a 2x2 block on the grid, makes sure diagonal touching doesnt happen.
nonTouching(Sol) :- nonTouchingRows(Sol).

nonTouchingRows([]).
nonTouchingRows([_]).
nonTouchingRows([R1,R2|Rest]) :-
    checkBlocksInRows(R1,R2),
    nonTouchingRows([R2|Rest]).

% Checks 2x2 blocks horizontally for any 2 consecutive rows.
checkBlocksInRows([],[]).
checkBlocksInRows([_],[_]).
checkBlocksInRows([A,B|R1],[C,D|R2]) :-
    cell_snake(A, SA), cell_snake(B, SB), cell_snake(C, SC), cell_snake(D, SD),
    (SA #/\ SD) #==> (SB #\/ SC),
    (SB #/\ SC) #==> (SA #\/ SD),
    checkBlocksInRows([B|R1],[D|R2]).

%countNeighbours
cellNeighbours(Cell, N, E, S, W) :-
    cell_snake(N, BN),
    cell_snake(E, BE),
    cell_snake(S, BS),
    cell_snake(W, BW),

    Neighbours #= BN + BE + BS + BW,
    Cell in 0..2,

    (Cell #= 1) #==> (Neighbours #= 1),
    (Cell #= 2) #==> (Neighbours #= 2),
    (Neighbours #= 0) #==> (Cell #= 0).

neighbour(Grid,X,Y,Cell) :-
    nth0(Y,Grid,Row),
    nth0(X,Row,Cell),
    !.
neighbour(_,_,_,0).

neighbours(Grid, X, Y, N, E, S, W) :-
    YN is Y-1,
    YS is Y+1,
    XE is X+1,
    XW is X-1,
    neighbour(Grid,X,YN,N),
    neighbour(Grid,XE,Y,E),
    neighbour(Grid,X,YS,S),
    neighbour(Grid,XW,Y,W).

countNeighbours(Grid) :-
    countNeighboursRows(Grid, 0, Grid).

countNeighboursRows([], _, _).
countNeighboursRows([Row|Rows], Y, Grid) :-
    countNeighboursRow(Row, 0, Y, Grid),
    Y1 is Y+1,
    countNeighboursRows(Rows, Y1, Grid).

countNeighboursRow([], _, _, _).
countNeighboursRow([Cell|Rest], X, Y, Grid) :-
    neighbours(Grid, X, Y, N, E, S, W),
    cellNeighbours(Cell, N, E, S, W),
    X1 is X+1,
    countNeighboursRow(Rest, X1, Y, Grid).

%check if there are only 2 heads.
head(Cell, Head) :-
    Head in 0..1,
    Head #<==> Cell #= 1.

twoHeads(Grid) :-
    append(Grid, Variable),
    maplist(head, Variable, Heads),
    sum(Heads, #=, 2).

%connectedSnake
findHead(Grid, (Y,X)) :-
    once((
        nth0(Y, Grid, Row),
        nth0(X, Row, 1)
    )).

snakeCell(1).
snakeCell(2).

countSnakeCells(Grid, Count) :-
    findall((Y,X),
        (
            nth0(Y,Grid,Row),
            nth0(X,Row,Cell),
            snakeCell(Cell)
        ),
        Cells),
    length(Cells, Count).

%adjacent is used in snakeNeighbours
adjacent(Grid, (Y,X), (YN, X)) :-
    YN is Y-1,
    YN >= 0,
    length(Grid, H),
    YN < H.
adjacent(Grid, (Y,X), (YS, X)) :-
    YS is Y+1,
    length(Grid, H),
    YS < H.
adjacent(_, (Y,X), (Y, XW)) :-
    XW is X-1,
    XW >= 0.
adjacent(Grid, (Y,X), (Y, XE)) :-
    XE is X+1,
    nth0(Y, Grid, Row),
    length(Row, W),
    XE < W.

%valueAt is used in snakeNeighbours
valueAt(Grid, (Y,X), Value) :-
    nth0(Y, Grid, Row),
    nth0(X, Row, Value).

%snakeNeighbours is used in dfs
snakeNeighbours(Grid, (Y,X), Neighbours) :-
    findall((YN,XN),
        (
            adjacent(Grid, (Y,X),(YN,XN)),
            valueAt(Grid,(YN,XN),Value),
            Value >= 1
        ),
        Neighbours).

%dfs is used in snakeConnected
dfs(_, [], Visited, Visited).
dfs(Grid, [Current|Stack], Seen, Result) :-
    member(Current, Seen),
    !,
    dfs(Grid, Stack, Seen, Result).
dfs(Grid, [Current|Stack], Seen, Result) :-
    snakeNeighbours(Grid, Current, Neighbours),
    append(Neighbours, Stack, NewStack),
    dfs(Grid, NewStack, [Current|Seen], Result).

snakeConnected(Grid) :-
    findHead(Grid, Head),
    dfs(Grid, [Head], [], Visited),
    length(Visited, Count),
    countSnakeCells(Grid, TotalCount),
    Count =:= TotalCount.
