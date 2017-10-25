%
% Setup
%

% Starts the game and picks a mode.
play :-
    write('Welcome to Othello!'),
    nl,
    write('Play against a friend: (h)'),
    nl,
    write('Play against the AI: (a)'),
    nl,
    write('Watch AI vs AI Deathmatch: (d)'),
    nl,
    read(Mode),
    start_game(Mode).

% Vs. Human, initiates board and possible moves list, black player goes first.
% start_game(Mode) is true if, Mode is 'h', (mode to play against
% another human).
start_game(Mode):-
    Mode = 'h',
    init_board(Board),
    print_board(Board),
    init_movelist(Movelist),!,
    play_human(Board,black,Movelist).

% Vs. AI, initiates board and possible moves list, player is black, AI is white.
% Selects the search depth of the AI.
% start_game(Mode) is true if, Mode is 'a' (mode to play against the
% AI).
start_game(Mode):-
    Mode = 'a',
    write('How strong should the AI be? (1,2,3...)?'),
    nl,
    write('Warning: if the level is too high, the game may be slow or crash.'),
    nl,
    read(Depth),
    init_board(Board),
    print_board(Board),
    init_movelist(Movelist),!,
    play_AI_human(Board,Depth,Movelist).

% AI Vs. AI, initiates board and possible moves list.
% Selects the search depth of both AI, and the frequency of which to
% print boards.
%start_game(Mode) is true if, Mode is 'd' (mode to watch two AI battle).
start_game(Mode):-
    Mode = 'd',
    write('select black strength: (1,2,3...)?'),
    nl,
    read(BDepth),
    write('select white strength: (1,2,3...)?'),
    nl,
    read(WDepth),
    write('How frequently do you want to print moves (1,2,3...)?'),
    nl,
    read(Freq),
    init_board(Board),
    init_movelist(Movelist),!,
    play_AI_black(Board,BDepth,WDepth,Freq,1,Movelist).


% Initial representation of the board.
% init_board(Board) is true if Board is the matrix represented below.
init_board(Board) :-
    Board = [[' ',' ',' ',' ',' ',' ',' ',' '],
             [' ',' ',' ',' ',' ',' ',' ',' '],
             [' ',' ',' ',' ',' ',' ',' ',' '],
             [' ',' ',' ','X','O',' ',' ',' '],
             [' ',' ',' ','O','X',' ',' ',' '],
             [' ',' ',' ',' ',' ',' ',' ',' '],
             [' ',' ',' ',' ',' ',' ',' ',' '],
             [' ',' ',' ',' ',' ',' ',' ',' ']].

% Initial list of potential moves for each player.
% init_movelist(Movelist) is true if Movelist is the list of
% coordinates represented below.
init_movelist(Movelist) :-
    Movelist = [[3,3],[3,4],[3,5],[3,6],[4,3],[4,6],[5,3],[5,6],[6,3],[6,4],[6,5],[6,6]].

%
% Main Game
%


% Human's move in an Vs. AI game.
% First checks if the game is over according to the rules.
play_AI_human(Board,_,Movelist) :-
    game_over(Board,'X',Movelist).
% play_AI_human is true if it prints the turn, selects and sets of move, update the movelists for each player, print the board,
% and play_AI runs the next turn for the AI.
% Board is the board the turn takes place on.
% Depth is the AI's search depth.
% Movelist is the list of potential moves given the board state.
play_AI_human(Board,Depth,Movelist) :-
    print_turn(black),
    player_symbol(black,S),
    select_move(X,Y),
    set_move(Board,X,Y,S,ResultBoard),
    update_movelist(Movelist,X,Y,Movelist1),
    add_new_moves(ResultBoard,Movelist1,X,Y,Movelist2),
    print_board(ResultBoard),
    play_AI(ResultBoard,Depth,Movelist2).

% AI's move in Vs. AI game.
% First checks if the game is over according to the rules.
play_AI(Board,_,Movelist) :-
    game_over(Board,'O',Movelist).
% play_AI is true if it prints the turn, selects and sets of move based on best_move, update the movelists for each player, print the board,
% and play_AI_human runs the next turn for the human.
% Board is the board the turn takes place on.
% Depth is the AI's search depth.
% Movelist is the list of potential moves given the board state.
play_AI(Board,Depth,Movelist) :-
    print_turn(white),
    player_symbol(white,S),
    limit_depth(Depth,Movelist,Depth1),
    best_move(Board,S,Depth1,Movelist,{X,Y},_),
    set_move_AI(Board,X,Y,S,ResultBoard),
    update_movelist(Movelist,X,Y,Movelist1),
    add_new_moves(ResultBoard,Movelist1,X,Y,Movelist2),
    print_board(ResultBoard),
    play_AI_human(ResultBoard,Depth,Movelist2).

% Black's turn in an AI Vs. AI game.
% First checks if the game is over according to the rules.
play_AI_black(Board,_,_,_,MoveCount,Movelist) :-
    game_over_ai(Board,'X',MoveCount,Movelist).
% play_AI_black is true if it prints the turn, selects and sets of move
% based on best_move, update the movelists for each player, print the
% board, and play_AI_human runs the next turn for the human. Board is
% the board the turn takes place on. Depth is the AI's search depth.
% Movelist is the list of potential moves given the board state.
% If the current turn number MoveCount is divisble by Freq, prints the
% board.
play_AI_black(Board,BDepth,WDepth,Freq,MoveCount,Movelist) :-
    0 is mod(MoveCount,Freq),
    MoveCount1 is MoveCount + 1,
    print_turn(black),
    player_symbol(black,S),
    write('Move: '),
    write(MoveCount),nl,
    limit_depth(BDepth,Movelist,BDepth1),
    best_move(Board,S,BDepth1,Movelist,{X,Y},_),
    set_move_AI(Board,X,Y,S,ResultBoard),
    update_movelist(Movelist,X,Y,Movelist1),
    add_new_moves(ResultBoard,Movelist1,X,Y,Movelist2),
    print_board(ResultBoard),
    play_AI_white(ResultBoard,BDepth,WDepth,Freq,MoveCount1,Movelist2).
% If the current turn number MoveCount is NOT divisble by Freq, does not
% print anything.
play_AI_black(Board,BDepth,WDepth,Freq,MoveCount,Movelist) :-
    MoveCount1 is MoveCount + 1,
    player_symbol(black,S),
    limit_depth(BDepth,Movelist,BDepth1),
    best_move(Board,S,BDepth1,Movelist,{X,Y},_),
    set_move_AI(Board,X,Y,S,ResultBoard),
    update_movelist(Movelist,X,Y,Movelist1),
    add_new_moves(ResultBoard,Movelist1,X,Y,Movelist2),
    play_AI_white(ResultBoard,BDepth,WDepth,Freq,MoveCount1,Movelist2).
% White's turn in an AI Vs. AI game.
% First checks if the game is over according to the rules.
play_AI_white(Board,_,_,_,MoveCount,Movelist) :-
    game_over_ai(Board,'O',MoveCount,Movelist).
% play_AI_white is true if it prints the turn, selects and sets of move
% based on best_move, update the movelists for each player, print the
% board, and play_AI_human runs the next turn for the human. Board is
% the board the turn takes place on. Depth is the AI's search depth.
% Movelist is the list of potential moves given the board state.
% If the current turn number MoveCount is divisble by Freq, prints the
% board.
play_AI_white(Board,BDepth,WDepth,Freq,MoveCount,Movelist) :-
    0 is mod(MoveCount,Freq),
    MoveCount1 is MoveCount + 1,
    print_turn(white),
    player_symbol(white,S),
    write('Move: '),
    write(MoveCount),nl,
    limit_depth(WDepth,Movelist,WDepth1),
    best_move(Board,S,WDepth1,Movelist,{X,Y},_),
    set_move_AI(Board,X,Y,S,ResultBoard),
    update_movelist(Movelist,X,Y,Movelist1),
    add_new_moves(ResultBoard,Movelist1,X,Y,Movelist2),
    print_board(ResultBoard),
    play_AI_black(ResultBoard,BDepth,WDepth,Freq,MoveCount1,Movelist2).
% If the current turn number MoveCount is NOT divisble by Freq, does not
% print anything.
play_AI_white(Board,BDepth,WDepth,Freq,MoveCount,Movelist) :-
    MoveCount1 is MoveCount + 1,
    player_symbol(white,S),
    limit_depth(WDepth,Movelist,WDepth1),
    best_move(Board,S,WDepth1,Movelist,{X,Y},_),
    set_move_AI(Board,X,Y,S,ResultBoard),
    update_movelist(Movelist,X,Y,Movelist1),
    add_new_moves(ResultBoard,Movelist1,X,Y,Movelist2),
    play_AI_black(ResultBoard,BDepth,WDepth,Freq,MoveCount1,Movelist2).


% Black's turn, Vs. Human game.
% First checks if the game is over according to the rules.
play_human(Board,black,Movelist) :-
    game_over(Board,'X',Movelist).
% play_human is true if it prints the turn for black, update black's possible move list Bmlist and white's possible move list Wmlist based on the selected move,
% with coordinates {X,Y}, runs play_human for white's turn with the new board ResultBoard.
% Board is the board the turn takes place on.
% Depth is the AI's search depth.
% Movelist is the list of potential moves given the board state.
play_human(Board,black,Movelist) :-
    print_turn(black),
    player_symbol(black,S),
    select_move(X,Y),
    set_move(Board,X,Y,S,ResultBoard),
    update_movelist(Movelist,X,Y,Movelist1),
    add_new_moves(ResultBoard,Movelist1,X,Y,Movelist2),
    print_board(ResultBoard),
    play_human(ResultBoard,white,Movelist2).

% White's turn, Vs. Human game.
% First checks if the game is over according to the rules.
play_human(Board,white,Movelist) :-
    game_over(Board,'O',Movelist).
% play_human is true if it prints the turn for white, update white's possible move list Wmlist and black's possible move list Bmlist based on the selected move,
% with coordinates {X,Y}, runs play_human for black's turn with the new board ResultBoard.
% Board is the board the turn takes place on.
% Depth is the AI's search depth.
% Movelist is the list of potential moves given the board state.
play_human(Board,white,Movelist) :-
    print_turn(white),
    player_symbol(white,S),
    select_move(X,Y),
    set_move(Board,X,Y,S,ResultBoard),
    update_movelist(Movelist,X,Y,Movelist1),
    add_new_moves(ResultBoard,Movelist1,X,Y,Movelist2),
    print_board(ResultBoard),
    play_human(ResultBoard,black,Movelist2).

% Game is over when a player has no valid moves to play on their turn.
% game_over(Board,Movelist) is true if any_move_valid() is false and
% announces the winner based on the count of each player's score.
game_over(Board,S,Movelist) :-
    \+any_move_valid(Board,S,Movelist),
    count(Board,'X',0,BScore),
    count(Board,'O',0,WScore),
    announce_winner(BScore,WScore).
% During AI Vs. AI, also prints the final board and turn number.
game_over_ai(Board,S,MoveCount,Movelist) :-
    \+any_move_valid(Board,S,Movelist),
    count(Board,'X',0,BScore),
    count(Board,'O',0,WScore),
    write('FINAL BOARD:'),nl,
    write('Move: '),
    write(MoveCount),nl,
    print_board(Board),
    announce_winner(BScore,WScore).

% Winner of the game is the player with the higher number of discs on the board.
% In the case black wins.
% announce_winner(BScore,WScore) is true if BScore is higher than WScore, prints the score of each player.
announce_winner(BScore,WScore) :-
    BScore > WScore,
    nl,
    write('Black has '),
    write(BScore),
    write(' points.'),
    nl,
    write('White has '),
    write(WScore),
    write(' points.'),
    nl,
    write('Black wins!').

% In the case white wins.
% announce_winner(BScore,WScore) is true if WScore is higher than BScore, prints the score of each player.
announce_winner(BScore,WScore) :-
    BScore < WScore,
    nl,
    write('Black has '),
    write(BScore),
    write(' points.'),
    nl,
    write('White has '),
    write(WScore),
    write(' points.'),
    nl,
    write('White wins!').

% In the case there is a tie, the scores are equal.
% announce_winner(BScore,WScore) is true if BScore and WScore are eqaul, prints the score of each winner.
announce_winner(BScore,WScore) :-
    BScore = WScore,
    nl,
    write('Black has '),
    write(BScore),
    write(' points.'),
    nl,
    write('White has '),
    write(WScore),
    write(' points.'),
    nl,
    write('Tie game!').

%
% AI
%


% Given board Board, get the value of the best move.
% best_move(Board,'X',Depth,BestMove,Vals) is true if for the black player, the coordinate BestMove,
% is the max value it could get without knowing what the other player will do.
% Board is the board to be tested.
% 'X' or 'O' is the symbol of the player
% Depth is the exponent of the number of boards to explore
% Movelist is the list of potential moves to iterate over
% BestMoves is the coords of the best move in form {X,Y}
% Val is the value associated with the best move.
best_move(Board,'X',Depth,Movelist,BestMove,Val) :-
	generate_boards(Board, 'X', Movelist, Boards, Movelists, Moves),
	compute_board_values(Boards, 'X', Depth, Movelists, Vals),
	select_best_move(max, Moves, Vals, BestMove, Val).

best_move(Board,'O',Depth,Movelist,BestMove,Val) :-
	generate_boards(Board, 'O', Movelist, Boards,Movelists,Moves),
	compute_board_values(Boards, 'O', Depth, Movelists, Vals),
	select_best_move(min, Moves, Vals, BestMove, Val).
% Generates a list of boards from a movelist, each with it's associated
% movelist and move.
% Board is the board from which new boards spawn.
% S is the player's symbol.
% Movelist is the list of potential moves to iterate over.
% Movelists is the ordered list of movelists associated with the boards.
% Boards is a list of boards after moves Moves are executed.
% Moves is the ordered list of moves associated with the boards.
generate_boards(Board, S, Movelist, Boards, Movelists, Moves) :-
        get_all_valid_moves(Board,S,Movelist,ValidMovelist),
        gen_boards_helper(Board, S,Movelist,ValidMovelist,Boards, Movelists, Moves).
gen_boards_helper(_,_,_,[],[],[],[]).
gen_boards_helper(Board, S, OrigMovelist,[[X,Y]|MovelistRest], Boards, [MListResult|Movelists], Moves) :-
	flip_lists(Board, S, Y, X, Fliplist),
	get_board_result(Board, S, Fliplist, X, Y, BResult, MResult),
	append(BResult, BRest, Boards),
	append(MResult, MRest, Moves),
	update_movelist(OrigMovelist,X,Y,NextMovelist),
        add_new_moves(BResult,NextMovelist,X,Y,MListResult),
	gen_boards_helper(Board,S,OrigMovelist,MovelistRest,BRest,Movelists,MRest).

% Given a list of moves and a board state, find which moves are valid
% Board is the board before the move to be test is placed upon it
% S is the symbol of the move to be placed
% X and Y are the coordinates of the move to be placed
% Rest is the rest of the coordinates to be tested
% List is the list of moves that passed testing
get_all_valid_moves(_,_,[],[]).
get_all_valid_moves(Board,S,[[X,Y]|Rest],[[X,Y]|List]) :-
    replace(Board,X,Y,S,ReplaceBoard),
    allowed_move(ReplaceBoard,S,X,Y),
    get_all_valid_moves(Board,S,Rest,List).
get_all_valid_moves(Board,S,[_|Rest],List) :-
    get_all_valid_moves(Board,S,Rest,List).


% Compute all board values in the Boards list.
% compute_board_values(Boards,S,Depth,Vals) is true if Vals is the list of values for each board in Boards,
% for each Depth for player with symbol S.
compute_board_values([],_,_,[],[]).
compute_board_values([],_,0,[],[]).
% Depth is 1.
compute_board_values([B|Boards], S, 1,_,[V|Vals]) :-
	board_value(B,V),
	compute_board_values(Boards, S, 1,_,Vals).
% Depth is more than 1.
compute_board_values([B|Boards],S,Depth,[MList|MListRest],[V|Vals]) :-
	Depth1 is Depth-1,
	other_symbol(S,OS),
	best_move(B,OS,Depth1,MList,_,V),
	compute_board_values(Boards, S, Depth, MListRest, Vals).


% Get board value. Number of black pieces minus number of white pieces.
% board_value(Board,R) is true if R is number of black discs minus number of white discs on the board Board.
board_value([], 0).
board_value([[]|Board], R) :-
	board_value(Board, R).

board_value([[' '|Row]|Board], R) :-
	board_value([Row|Board], R).

board_value([['X'|Row]|Board], R) :-
	board_value([Row|Board], RR),
	R is RR+1.

board_value([['O'|Row]|Board], R) :-
	board_value([Row|Board], RR),
	R is RR-1.

% Get board after flipping all required pieces.
% get_board_result(Board,S,Fliplist,X,Y,BResult,Move) is true if BResult is the board as a result of the move Move {X,Y} from Fliplist,
% on the current Board for player with symbol S.
get_board_result(_, _, [], _, _, [], []).
get_board_result(Board, S, Fliplist, X, Y, [BRes], [{X,Y}]) :-
	replace_all(Board, [{X,Y}|Fliplist], S, BRes).

% Select the move with the best corresponding board value.
% Based on Minimax (maximize the minimum gain).
% select_best_move(max,Moves,Vals,MRes,VRes) is true if MRes is the best move and VRes is the best value,
% obtainined by comparing the values in Vals of each move in Moves and taking the greater value.
% select_best_move(max,Moves,Vals,MRes,VRes) is true if MRes is the best move and VRes is the best value,
% obtainined by comparing the values in Vals of each move in Moves and taking the lower value.
select_best_move(max, Moves, Vals, MRes, VRes) :-
	select_best_move(max, Moves, Vals, {1,1}, -1000000, MRes, VRes).
select_best_move(min, Moves, Vals, MRes, VRes) :-
	select_best_move(min, Moves, Vals, {1,1}, 1000000, MRes, VRes).
select_best_move(_, [], [], M, V, M, V).
select_best_move(min, [M|Moves], [V|Vals],_, ValCur, MoveRes, ValRes) :-
	ValCur > V,
	select_best_move(min, Moves, Vals, M, V, MoveRes, ValRes).
select_best_move(min, [_|Moves], [V|Vals], MoveCur, ValCur, MoveRes, ValRes) :-
	ValCur < V,
	select_best_move(min, Moves, Vals, MoveCur, ValCur, MoveRes, ValRes).
select_best_move(min, [_|Moves], [V|Vals], MoveCur, V, MoveRes, ValRes) :-
	select_best_move(min, Moves, Vals, MoveCur, V, MoveRes, ValRes).
select_best_move(max, [M|Moves], [V|Vals],_, ValCur, MoveRes, ValRes) :-
	ValCur < V,
	select_best_move(max, Moves, Vals, M, V, MoveRes, ValRes).
select_best_move(max, [_|Moves], [V|Vals], MoveCur, ValCur, MoveRes, ValRes) :-
	ValCur > V,
	select_best_move(max, Moves, Vals, MoveCur, ValCur, MoveRes, ValRes).
select_best_move(max, [_|Moves], [V|Vals], MoveCur, V, MoveRes, ValRes) :-
	select_best_move(max, Moves, Vals, MoveCur, V, MoveRes, ValRes).

% Helper that counts how many elements there are in a list
% [H|T] is the list
% S is the sum accumulator
% C is the final count
count_list([],C,C).
count_list([H|T],S,C) :-
	\+(H = []),
	S1 is S + 1,
	count_list(T,S1,C).
% Stops the AI from causing stack overflow on higher depths by limiting
% the depth to 2 if the problem domain is too large.
% Depth is the proposed depth of search.
% List is the list of moves to be explored.
% Depth1 is the limited depth to be used.
limit_depth(Depth,List,Depth1) :-
	count_list(List,0,Count),
	Count < 15,
	Depth1 = Depth.
limit_depth(_,_,Depth1) :-
	Depth1 = 2.



%
% Game Utility
%

% Determines if a given list of moves contains even one allowed move.
% Board is the board before any new moves are added.
% S is the player symbol.
% X and Y are the coordinates of the move.
any_move_valid(Board,S,[[X,Y]|_]) :-
    replace(Board,X,Y,S,ReplaceBoard),
    allowed_move(ReplaceBoard,S,X,Y).
any_move_valid(Board,S,[_|Rest]) :-
    any_move_valid(Board,S,Rest).


% Removes a moved from a given movelist, if it exists.
% update_movelist(Movelist,X,Y,Endlist) is true if the coordinate {X,Y} is a member of Movelist and gets deleted from MoveList resulting in Endlist.
update_movelist(Movelist,X,Y,Endlist) :-
    member([X,Y],Movelist),
    delete(Movelist,[X,Y],Endlist).
update_movelist(L,_,_,L).

% Creates an updated list of possible moves.
% add_new_moves(Board,S,Movelist,X,Y,Endlist) is true if Endlist is result of appending MoveList and a list of new moves,
% created by checking all surrounding coordinates of {X,Y} for the player with symbol S on the current board Board.
% Board is the board including the move placed at coords X,Y.
% Movelist is the list of moves that new moves are added to.
% Endlist is the final list of moves
add_new_moves(Board,Movelist,X,Y,Endlist) :-
    check_coord(Board,X,Y,-1,0,Movelist,CUp),
    check_coord(Board,X,Y,1,0,Movelist,CDown),
    check_coord(Board,X,Y,0,-1,Movelist,CLeft),
    check_coord(Board,X,Y,0,1,Movelist,CRight),
    check_coord(Board,X,Y,-1,-1,Movelist,CUL),
    check_coord(Board,X,Y,-1,1,Movelist,CUR),
    check_coord(Board,X,Y,1,-1,Movelist,CDL),
    check_coord(Board,X,Y,1,1,Movelist,CDR),
    create_list(CUp,[],L1),
    create_list(CDown,L1,L2),
    create_list(CLeft,L2,L3),
    create_list(CRight,L3,L4),
    create_list(CUL,L4,L5),
    create_list(CUR,L5,L6),
    create_list(CDL,L6,L7),
    create_list(CDR,L7,L8),
    append(Movelist,L8,Endlist).

% Adds Item to the list List.
% create_list(Item,List,List1) is true if List2 contains Item from List1.
create_list([],List,List).
create_list(Item,List,[Item|List]).

% Check if a move can be placed in possible move list.
% Move should not be in the MoveList already.
% check_coord(Board,S,X,Y,Xmod,Ymod,Movelist,Coord) is true if {Xmod,Ymod} are offset variables for {X,Y} that represent the adjacent spaces,
% in all 8 directions for player with symbol S on the current board Board, Coord is the coordinate in the offset of {X,Y} ({X1,Y1}), and we make sure,
% this coordinated [X1,Y1] is empty on the board, an allowed move and
% not a member of Movelist.
check_coord(Board,X,Y,Xmod,Ymod,Movelist,Coord) :-
    X1 is X + Xmod,
    Y1 is Y + Ymod,
    member(X1,[1,2,3,4,5,6,7,8]),
    member(Y1,[1,2,3,4,5,6,7,8]),
    placed(Board,' ',X1,Y1),
    \+member([X1,Y1],Movelist),
    Coord = [X1,Y1].
check_coord(_,_,_,_,_,_,[]).

% Prints the board.
% print_board(Board) is true if it prints the column numbers and the board.
print_board(Board) :-
    write('   1   2   3   4   5   6   7   8'),
    nl,
    write('  -------------------------------'),
    nl,
    print_rows(Board,1).

% Print the board.
% print_rows(Board,N) is true if it prints the row numbers and the board rows.
print_rows([],9).
print_rows([Row|Rest],N) :-
    write(N),
    write('  '),
    N1 is N+1,
    print_row(Row),
    nl,
    write('  -------------------------------'),
    nl,
    print_rows(Rest,N1).

% Prints the board.
% print_row(Board) is true if it prints each row of the board.
print_row([]).
print_row([H|T]) :-
    write(H),
    write(' | '),
    print_row(T).

% Print which player's turn it is.
% print_turn(Color) is true if it prints the current turn's player.
print_turn(Color) :-
    nl,
    write('Player Turn: '),
    write(Color),nl.

% Ask player to choose a move.
% select_move(X,Y) is true if the human types a possible X-coordinate and possible Y-coordinate.
select_move(X,Y) :-
    write('Pick a row: '),
    nl,
    read(X),
    member(X,[1,2,3,4,5,6,7,8]),
    write('Pick a column: '),
    nl,
    read(Y),
    member(Y,[1,2,3,4,5,6,7,8]).
select_move(X,Y) :-
    write('Error, try again'),
    nl,
    write('Pick a row: '),
    nl,
    read(X),
    member(X,[1,2,3,4,5,6,7,8]),
    write('Pick a column: '),
    nl,
    read(Y),
    member(Y,[1,2,3,4,5,6,7,8]).


% Set the move if possible.
% set_move(StartBoard,X,Y,S,EndBoard) is true if the coordinate {X,Y} has an empty space on StartBoard, places the piece on PlacedBoard and flips (outflank),
% the pieces based on the move made at {X,Y} results in EndBoard.
set_move(StartBoard,X,Y,S,EndBoard) :-
    placed(StartBoard,' ',X,Y),
    replace(StartBoard,X,Y,S,PlacedBoard),!,
    allowed_move(PlacedBoard,S,X,Y),
    flip(PlacedBoard,X,Y,S,EndBoard),!.

% The AI checks for move validity during search, so it does not check
% again when placing a move.
set_move_AI(StartBoard,X,Y,S,EndBoard) :-
    replace(StartBoard,X,Y,S,PlacedBoard),!,
    flip(PlacedBoard,X,Y,S,EndBoard),!.


% Symbols for the players.
% player_symbol(Color,S) is true if player Color's symbol on the game board is S.
player_symbol(black,'X').
player_symbol(white,'O').

% Replace on the board with specified disc (S).
% replace(List,X,Y,S,List1) is true if List1 is the result of replacing the {X,Y} coordinate with S in List.
% Finds the row (X-coordinate), while replace_column finds the column (Y-coordinate).
replace([OrigRow1|Rest],1,Y,S,[NewRow1|Rest]) :-
    replace_column(OrigRow1,Y,S,NewRow1).
replace([OrigRow1|OrigRest],X,Y,S,[OrigRow1|NewRest]) :-
    X > 1,
    X1 is X-1,
    replace(OrigRest,X1,Y,S,NewRest).
% replace_column(List,Y,S,List1) is true if List1 is the result of replacing the Y-coordinate (just the column) with S in List.
replace_column([_|Cs],1,S,[S|Cs]).
replace_column([C|Cs],Y,S,[C|Rs]) :-
    Y > 1 ,
    Y1 is Y-1 ,
    replace_column(Cs,Y1,S,Rs).

% Represents the opposing player's symbol.
% other_symbol(S,OS) is true if the player's symbol is S, and OS is the
% opposing player's symbol.
other_symbol('X','O').
other_symbol('O','X').

% A disc of player Color, is placed at position X,Y.
% placed(Board,S,X,Y) is true if there is a player's symbol S placed on the Board at coordinate {X,Y}.
placed(Board,S,X,Y) :-
    nth1(X,Board,Col),
    nth1(Y,Col,S).

% Flip a disc to make other color.
% flip(Board,Y,X,S,ResultBoard) is true if ResultBoard is the result of flipping all the discs of the opposing player based on the move,
% made by player with symbol S with coordinate {X,Y} on the board Board.
flip(Board,Y,X,S,ResultBoard) :-
    flip_lists(Board, S, X, Y, Allflips),
    replace_all(Board,Allflips,S,ResultBoard).

% Count the number of discs NPieces of the player.
% count(Board,S,Count,Sum) is true if Sum is the number of all discs on the board Board of player with symbol S,
% Count is equal to Sum, used with recursion to keep count of discs visited.
% Uses count_row to get number of discs in each row, and sums.
count([],_,S,S).
count([Row|Rest],S,0,Sum) :- count_row(Row,S,0,RowSum), count(Rest,S,RowSum,Sum).
count([Row|Rest],S,Count,Sum) :- count_row(Row,S,0,RowSum), Count1 is RowSum + Count, count(Rest,S,Count1,Sum).
% count_row(Row,S,Count,Sum) is true if Sum is the number of all discs in Row of player with symbol S.
count_row([],_,S,S).
count_row([H|T],H,0,Sum) :- count_row(T,H,1,Sum).
count_row([_|T],S,0,Sum) :- count_row(T,S,0,Sum).
count_row([H|T],H,Count,Sum) :- Count1 is Count+1, count_row(T,H,Count1,Sum).
count_row([_|T],S,Count,Sum) :- count_row(T,S,Count,Sum).

% Finds the bordering piece,
% bordering_piece_helper(Board,X,Y,IX,IY,DX,DY,S,Res) is true if {IX,IY} is a bordering piece stored as Res, given {X,Y} (position of initial check) and,
% {DX,DY} (directional offsets), for player with symbol S on board Board.
% {IX,IY} is a bordering piece if row Y doesn't exist, IY is most top row.
bordering_piece_helper(_, _, Y, IX, IY, _, _, _, {IX,IY}) :-
	Y < 1.
% {IX,IY} is a bordering piece if row Y doesn't exist, IY is most bottom row.
bordering_piece_helper(_, _, Y, IX, IY, _, _, _, {IX,IY}) :-
	Y > 8.
% {IX,IY} is a bordering piece if column X doesn't exist, IX is most left column.
bordering_piece_helper(_, X, _, IX, IY, _, _, _, {IX,IY}) :-
	X < 1.
% {IX,IY} is a bordering piece if column X doesn't exist, IX is most right column.
bordering_piece_helper(_, X, _, IX, IY, _, _, _, {IX,IY}) :-
	X > 8.
% {IX,IY} is a bordering piece if {X,Y} is empty.
bordering_piece_helper(Board, X, Y, IX, IY, _, _, _, {IX,IY}) :-
	placed(Board,' ',Y,X).
% {X,Y} is a bordering piece, if there is a disc of the same color placed there.
% HELP (Should it be {IX,IY}?)
bordering_piece_helper(Board, X, Y, _, _, _, _, S, {X,Y}) :-
	placed(Board,S,Y,X).
% Finds the bordering piece using directional offsets DX and DY.
bordering_piece_helper(Board, X, Y, IX, IY, DX, DY, S, Res) :-
	NX is X+DX,
	NY is Y+DY,
	bordering_piece_helper(Board, NX, NY, IX, IY, DX, DY, S, Res).

% Looks for bordering piece above.
% top_bordering_piece(Board,X,Y,S,Res) is true if on the board Board, for a disc at coordinate {X,Y} stored as Res, of player with symbol S,
% is a top bordering piece.
% {X,Y} is the top bordering piece if it is in the first two rows.
top_bordering_piece(_, X, Y, _, {X,Y}) :-
	Y < 3.
% {X,Y} is the top bordering piece if if there is a disc of the same color 1 space above.
top_bordering_piece(Board, X, Y, S, {X,Y}) :-
	Y1 is Y-1,
	placed(Board,S,Y1,X).
% {X,Y} is the top bordering piece if its empty 1 space above.
top_bordering_piece(Board, X, Y, _, {X,Y}) :-
	Y1 is Y-1,
	placed(Board,' ',Y1,X).
% Finds top bordering piece if its more than 1 space above.
top_bordering_piece(Board, X, Y, S, Res) :-
	Y1 is Y-2,
	bordering_piece_helper(Board, X, Y1, X, Y, 0, -1, S, Res).

% Looks for bordering piece above.
% bottom_bordering_piece(Board,X,Y,S,Res) is true if on the board Board, for a disc at coordinate {X,Y} stored as Res, of player with symbol S,
% is a bottom bordering piece.
% {X,Y} is the bottom bordering piece if its in the last two rows.
bottom_bordering_piece(_, X, Y, _, {X,Y}) :-
	Y > 6.
% {X,Y} is the bottom bordering piece if there is a disc of the same color 1 space below.
bottom_bordering_piece(Board, X, Y, S, {X,Y}) :-
	Y1 is Y+1,
	placed(Board,S,Y1,X).
% {X,Y} is the bottom bordering piece if its empty 1 space below.
bottom_bordering_piece(Board, X, Y, _, {X,Y}) :-
	Y1 is Y+1,
	placed(Board,' ',Y1,X).
% Finds bottom bordering piece if its more than 1 space below.
bottom_bordering_piece(Board, X, Y, S, Res) :-
	Y1 is Y+2,
	bordering_piece_helper(Board, X, Y1, X, Y, 0, 1, S, Res).

% Looks for bordering piece to the left.
% left_bordering_piece(Board,X,Y,S,Res) is true if on the board Board, for a disc at coordinate {X,Y} stored as Res, of player with symbol S,
% is a left bordering piece.
% {X,Y} is the left bordering piece if its in the first two columns.
left_bordering_piece(_, X, Y, _, {X,Y}) :-
	X < 3.
% {X,Y} is the left bordering piece if there is a disc of the same color 1 space to the left.
left_bordering_piece(Board, X, Y, S, {X,Y}) :-
	X1 is X-1,
	placed(Board,S,Y,X1).
% {X,Y} is the left bordering piece if its empty 1 space to the left.
left_bordering_piece(Board, X, Y, _, {X,Y}) :-
	X1 is X-1,
	placed(Board,' ',Y,X1).
% Finds left bordering piece if its more than 1 space to the left.
left_bordering_piece(Board, X, Y, S, Res) :-
	X1 is X-2,
	bordering_piece_helper(Board, X1, Y, X, Y, -1, 0, S, Res).

% Looks for bordering piece in the right.
% right_bordering_piece(Board,X,Y,S,Res) is true if on the board Board, for a disc at coordinate {X,Y} stored as Res, of player with symbol S,
% is a right bordering piece.
% {X,Y} is the right bordering piece if its in the last two columns.
right_bordering_piece(_, X, Y, _, {X,Y}) :-
	X > 6.
% {X,Y} is the right bordering piece if there is a disc of the same color 1 space to the right.
right_bordering_piece(Board, X, Y, S, {X,Y}) :-
	X1 is X+1,
	placed(Board,S,Y,X1).
% {X,Y} is the right bordering piece if its empty 1 space to the right.
right_bordering_piece(Board, X, Y, _, {X,Y}) :-
	X1 is X+1,
	placed(Board,' ',Y,X1).
% Finds right bordering piece if its more than 1 space to the right.
right_bordering_piece(Board, X, Y, S, Res) :-
	X1 is X+2,
	bordering_piece_helper(Board, X1, Y, X, Y, 1, 0, S, Res).

% Looks for bordering piece in top left diagonal.
% top_left_bordering_piece(Board,X,Y,S,Res) is true if on the board Board, for a disc at coordinate {X,Y}, stored as Res, of player with symbol S,
% is a top left bordering piece.
% {X,Y} is the top left bordering piece if its in the first two columns.
top_left_bordering_piece(_, X, Y, _, {X,Y}) :-
	X < 3.
% {X,Y} is the top left bordering piece it its in the first two rows.
top_left_bordering_piece(_, X, Y, _, {X,Y}) :-
	Y < 3.
% {X,Y} is the top left bordering piece if there is a disc of the same color 1 space in top left.
top_left_bordering_piece(Board, X, Y, S, {X,Y}) :-
	X1 is X-1,
	Y1 is Y-1,
	placed(Board,S,Y1,X1).
% {X,Y} is the top left bordering piece if its empty 1 space in top left.
top_left_bordering_piece(Board, X, Y, _, {X,Y}) :-
	X1 is X-1,
	Y1 is Y-1,
	placed(Board,' ',Y1,X1).
% Finds the top left bordering piece if its more than 1 space in top left direction.
top_left_bordering_piece(Board, X, Y, S, Res) :-
	X1 is X-2,
	Y1 is Y-2,
	bordering_piece_helper(Board, X1, Y1, X, Y, -1, -1, S, Res).

% Looks for bordering piece in top right diagonal.
% top_right_bordering_piece(Board,X,Y,S,Res) is true if on the board Board, for a disc at coordinate {X,Y}, stored as Res, of player with symbol S,
% is a top right bordering piece.
% {X,Y} is the top right bordering piece if its in the last two columns.
top_right_bordering_piece(_, X, Y, _, {X,Y}) :-
	X > 6.
% {X,Y} is the top right bordering piece if its in the first two rows.
top_right_bordering_piece(_, X, Y, _, {X,Y}) :-
	Y < 3.
% {X,Y} is the top right bordering piece if there is a disc of the same color 1 space in top right.
top_right_bordering_piece(Board, X, Y, S, {X,Y}) :-
	X1 is X+1,
	Y1 is Y-1,
	placed(Board,S,Y1,X1).
% {X,Y} is the top right bordering piece if its empty 1 space in top right.
top_right_bordering_piece(Board, X, Y, _, {X,Y}) :-
	X1 is X+1,
	Y1 is Y-1,
	placed(Board,' ',Y1,X1).
% Finds the top right bordering piece if its more than 1 space in top right direction.
top_right_bordering_piece(Board, X, Y, S, Res) :-
	X1 is X+2,
	Y1 is Y-2,
	bordering_piece_helper(Board, X1, Y1, X, Y, +1, -1, S, Res).

% Looks for bordering piece in bottom right diagonal.
% bottom_left_bordering_piece(Board,X,Y,S,Res) is true if on the board Board, for a disc at coordinate {X,Y}, stored as Res, of player with symbol S,
% is a bottom left bordering piece.
% {X,Y} is the bottom left bordering piece if its in the first two columns.
bottom_left_bordering_piece(_, X, Y, _, {X,Y}) :-
	X < 3.
% {X,Y} is the bottom left bordering piece if its in the last two rows.
bottom_left_bordering_piece(_, X, Y, _, {X,Y}) :-
	Y > 6.
% {X,Y} is the bottom left bordering piece if there is a disc of the same color 1 space in bottom left.
bottom_left_bordering_piece(Board, X, Y, S, {X,Y}) :-
	X1 is X-1,
	Y1 is Y+1,
	placed(Board,S,Y1,X1).
% {X,Y} is the bottom left bordering piece if its empty 1 space in bottom left.
bottom_left_bordering_piece(Board, X, Y, _, {X,Y}) :-
	X1 is X-1,
	Y1 is Y+1,
	placed(Board,' ',Y1,X1).
% Finds the bottom left bordering piece if its more than 1 space in bottom left direction.
bottom_left_bordering_piece(Board, X, Y, S, Res) :-
	X1 is X-2,
	Y1 is Y+2,
	bordering_piece_helper(Board, X1, Y1, X, Y, -1, +1, S, Res).

% Looks for bordering piece in bottom right diagonal.
% bottom_right_bordering_piece(Board,X,Y,S,Res) is true if on the board Board, for a disc at coordinate {X,Y}, stored as Res, of player with symbol S,
% is a bottom right bordering piece.
% {X,Y} is the right bordering piece if its in the last two columns.
bottom_right_bordering_piece(_, X, Y, _, {X,Y}) :-
	X > 6.
% {X,Y} is the right bordering piece if its in the last two rows.
bottom_right_bordering_piece(_, X, Y, _, {X,Y}) :-
	Y > 6.
% {X,Y} is the right bordering piece if there is a disc of the same color 1 space in bottom right.
bottom_right_bordering_piece(Board, X, Y, S, {X,Y}) :-
	X1 is X+1,
	Y1 is Y+1,
	placed(Board,S,Y1,X1).
% {X,Y} is the right bordering piece if its empty 1 space in bottom right.
bottom_right_bordering_piece(Board, X, Y, _, {X,Y}) :-
	X1 is X+1,
	Y1 is Y+1,
	placed(Board,' ',Y1,X1).
% Finds the bottom right bordering piece if its more than 1 space in bottom right direction.
bottom_right_bordering_piece(Board, X, Y, S, Res) :-
	X1 is X+2,
	Y1 is Y+2,
	bordering_piece_helper(Board, X1, Y1, X, Y, +1, +1, S, Res).

% Reverts a list of {X,Y} to a list of {Y,X}.
% revert(List,RList) is true if Rlist is the result of reverting coordinates in List.
revert_x_y([],[]).
revert_x_y([{X,Y}|List],[{Y,X}|RList]) :-
	revert_x_y(List,RList).

% Replaces (flips) all the pieces that are in the flipping list.
% replace_all(Board,Fliplist,S,Result) is true if Result is the result of replacing elements in Board according to Sfliplist,
% for player with symbol S.
replace_all(Board, Fliplist, S, Result) :-
	revert_x_y(Fliplist, Fliplist1),
	sort(Fliplist1, Sfliplist1),
	revert_x_y(Sfliplist1, Sfliplist),
	replace_all(Board, Sfliplist, S, 1, 1, Result).
replace_all(Board, [], _, _, _,Board).
replace_all([[]|Board], Fliplist, S, 9, Yit, [[]|Result]) :-
	Yit1 is Yit+1,
	replace_all(Board, Fliplist, S, 1, Yit1, Result).
replace_all([[_|Row]|Board], [{Xit,Yit}|Fliplist], S, Xit, Yit, [[S|ResRow]|ResBoard]) :-
	Xit1 is Xit+1,
	replace_all([Row|Board], Fliplist, S, Xit1, Yit, [ResRow|ResBoard]).
replace_all([[Piece|Row]|Board], [{X,Y}|Fliplist], S, Xit, Yit, [[Piece|ResRow]|ResBoard]) :-
	Xit1 is Xit+1,
	X \== Xit,
	replace_all([Row|Board], [{X,Y}|Fliplist], S, Xit1, Yit, [ResRow|ResBoard]).
replace_all([[Piece|Row]|Board], [{X,Y}|Fliplist], S, Xit, Yit, [[Piece|ResRow]|ResBoard]) :-
	Xit1 is Xit+1,
	Y \== Yit,
	replace_all([Row|Board], [{X,Y}|Fliplist], S, Xit1, Yit, [ResRow|ResBoard]).

% Gets all the coordinates within the range of the bordering piece.
% coords_in_range(Coord,Coord1,List) is true if List is the result of all coordinates between Coord and Coord1.
coords_in_range({X,Y}, {X,Y}, []).
% Not in range, don't add to List.
coords_in_range({X1, Y1}, {X2, Y2}, []) :-
	Y2 is Y1 + (Y2-Y1)/max(1,abs(Y2-Y1)),
	X2 is X1 + (X2-X1)/max(1,abs(X2-X1)).
% In the range.
coords_in_range({X1,Y1}, {X2,Y2}, [{X11, Y11}|List]) :-
	Y11 is Y1 + (Y2-Y1)/max(1,abs(Y2-Y1)),
	X11 is X1 + (X2-X1)/max(1,abs(X2-X1)),
	coords_in_range({X11,Y11},{X2,Y2},List).

% Gets list of all pieces that need to be flipped (outflanking).
% flip_lists(Board,S,X,Y,Allflips) is true if Allflips is a list of all coordinates on the board Board that need to be flipped,
% for player with symbol S, in all 8 directions.
flip_lists(Board, S, X, Y, Allflips) :-
	left_bordering_piece(Board, X, Y, S, Lpiece),
	right_bordering_piece(Board, X, Y, S, Rpiece),
	top_bordering_piece(Board, X, Y, S, Tpiece),
	bottom_bordering_piece(Board, X, Y, S, Bpiece),
	bottom_left_bordering_piece(Board, X, Y, S, BLpiece),
	bottom_right_bordering_piece(Board, X, Y, S, BRpiece),
	top_left_bordering_piece(Board, X, Y, S, TLpiece),
        top_right_bordering_piece(Board, X, Y, S, TRpiece),
        coords_in_range({X, Y}, Lpiece, Llist),
	coords_in_range({X, Y}, Rpiece, Rlist),
	coords_in_range({X, Y}, Tpiece, Tlist),
	coords_in_range({X, Y}, Bpiece, Blist),
	coords_in_range({X, Y}, BLpiece, BLlist),
	coords_in_range({X, Y}, BRpiece, BRlist),
	coords_in_range({X, Y}, TLpiece, TLlist),
	coords_in_range({X, Y}, TRpiece, TRlist),
	append(Rlist, Llist, L1),
	append(L1, Tlist, L2),
	append(L2, Blist, L3),
	append(L3, BLlist, L4),
	append(L4, BRlist, L5),
	append(L5, TLlist, L6),
	append(L6, TRlist, Allflips).


%
% Game Rules
%

% Allowed move only if you can "outflank" the opponenet's discs.
% You must place your disc to "outflank" opponent, you cannot "outflank" your own disc, a disc should be placed 1 space above, below, to the left, right,
% upper-left, upper-right, lower-left, lower-right of an opposing player's disc.

% allowed_move(Board,S,X,Y) is true if {X,Y} is an allowed move on board Board for player with symbol S.
% Disc above.
allowed_move(Board,S,X,Y) :-
    X1 is X-1,
    Y1 is Y,
    other_symbol(S,OS),
    placed(Board,OS,X1,Y),
    cappedUp(Board,OS,X1,Y1).

% Disc below.
allowed_move(Board,S,X,Y) :-
    X1 is X+1,
    other_symbol(S,OS),
    placed(Board,OS,X1,Y),
    cappedDown(Board,OS,X1,Y).

% Disc to left.
allowed_move(Board,S,X,Y) :-
    Y1 is Y-1,
    other_symbol(S,OS),
    placed(Board,OS,X,Y1),
    cappedLeft(Board,OS,X,Y1).

% Disc to right.
allowed_move(Board,S,X,Y) :-
    Y1 is Y+1,
    other_symbol(S,OS),
    placed(Board,OS,X,Y1),
    cappedRight(Board,OS,X,Y1).


% Disc to diagonal upper left.
allowed_move(Board,S,X,Y) :-
    X1 is X-1,
    Y1 is Y-1,
    other_symbol(S,OS),
    placed(Board,OS,X1,Y1),
    cappedUL(Board,OS,X1,Y1).

% Disc to diagonal upper right.
allowed_move(Board,S,X,Y) :-
    X1 is X-1,
    Y1 is Y+1,
    other_symbol(S,OS),
    placed(Board,OS,X1,Y1),
    cappedUR(Board,OS,X1,Y1).

% Disc to diagonal down left.
allowed_move(Board,S,X,Y) :-
    X1 is X+1,
    Y1 is Y-1,
    other_symbol(S,OS),
    placed(Board,OS,X1,Y1),
    cappedDL(Board,OS,X1,Y1).

% Disc to diagonal down right.
allowed_move(Board,S,X,Y) :-
    X1 is X+1,
    Y1 is Y+1,
    other_symbol(S,OS),
    placed(Board,OS,X1,Y1),
    cappedDR(Board,OS,X1,Y1).


% The board is capped (contains opposing player's disc on the edge) above.
% cappedUp(Board,S,X,Y) is true if on the board Board for player with symbol S, the opposing player's disc is placed 1 space up.
cappedUp(Board,S,X,Y) :-
    X > 1,
    X1 is X-1,
    other_symbol(S,OS),
    placed(Board,OS,X1,Y),!.
% cappedUp(Board,S,X,Y) is true if on the board Board for player with symbol S, the opposing player's disc is placed more than 1 space up.
cappedUp(Board,S,X,Y) :-
    X > 2,
    X1 is X-1,
    placed(Board,S,X1,Y),
    cappedUp(Board,S,X1,Y).

% The board is capped below.
% cappedDown(Board,S,X,Y) is true if on the board Board for player with symbol S, the opposing player's disc is placed 1 space below.
cappedDown(Board,S,X,Y) :-
    X < 8,
    X1 is X+1,
    other_symbol(S,OS),
    placed(Board,OS,X1,Y),!.
% cappedDown(Board,S,X,Y) is true if on the board Board for player with symbol S, the opposing player's disc is placed more than 1 space below.
cappedDown(Board,S,X,Y) :-
    X < 7,
    X1 is X+1,
    placed(Board,S,X1,Y),
    cappedDown(Board,S,X1,Y).

% The board is capped to the left.
% cappedLeft(Board,S,X,Y) is true if on the board Board for player with symbol S, the opposing player's disc is placed 1 space to the left.
cappedLeft(Board,S,X,Y) :-
    Y > 1,
    Y1 is Y-1,
    other_symbol(S,OS),
    placed(Board,OS,X,Y1),!.
% cappedLeft(Board,S,X,Y) is true if on the board Board for player with symbol S, the opposing player's disc is placed more than 1 space to the left.
cappedLeft(Board,S,X,Y) :-
    Y > 2,
    Y1 is Y-1,
    placed(Board,S,X,Y1),
    cappedLeft(Board,S,X,Y1).

% The board is capped to the right.
% cappedRight(Board,S,X,Y) is true if on the board Board for player with symbol S, the opposing player's disc is placed 1 space to the right.
cappedRight(Board,S,X,Y) :-
    Y < 8,
    Y1 is Y+1,
    other_symbol(S,OS),
    placed(Board,OS,X,Y1),!.
% cappedRight(Board,S,X,Y) is true if on the board Board for player with symbol S, the opposing player's disc is placed more than 1 space to the right.
cappedRight(Board,S,X,Y) :-
    Y < 7,
    Y1 is Y+1,
    placed(Board,S,X,Y1),
    cappedRight(Board,S,X,Y1).

% The board is capped in the upper left diagonal direction.
% cappedUL(Board,S,X,Y) is true if on the board Board for player with symbol S, the opposing player's disc is placed 1 space to the upper-left.
cappedUL(Board,S,X,Y) :-
    X > 1,
    Y > 1,
    X1 is X-1,
    Y1 is Y-1,
    other_symbol(S,OS),
    placed(Board,OS,X1,Y1),!.
% cappedUL(Board,S,X,Y) is true if on the board Board for player with symbol S, the opposing player's disc is placed more than 1 space to the upper-left.
cappedUL(Board,S,X,Y) :-
    X > 2,
    Y > 2,
    X1 is X-1,
    Y1 is Y-1,
    placed(Board,S,X1,Y1),
    cappedUL(Board,S,X1,Y1).

% The board is capped in the upper right diagonal direction.
% cappedUR(Board,S,X,Y) is true if on the board Board for player with symbol S, the opposing player's disc is placed 1 space to the upper-right.
cappedUR(Board,S,X,Y) :-
    X > 1,
    Y < 8,
    X1 is X-1,
    Y1 is Y+1,
    other_symbol(S,OS),
    placed(Board,OS,X1,Y1),!.
% cappedUR(Board,S,X,Y) is true if on the board Board for player with symbol S, the opposing player's disc is placed more than 1 space to the upper-right.
cappedUR(Board,S,X,Y) :-
    X > 2,
    Y < 7,
    X1 is X-1,
    Y1 is Y+1,
    placed(Board,S,X1,Y1),
    cappedUR(Board,S,X1,Y1).

% The board is capped in the lower left diagonal direction.
% cappedDL(Board,S,X,Y) is true if on the board Board for player with symbol S, the opposing player's disc is placed 1 space to the lower-left.
cappedDL(Board,S,X,Y) :-
    X < 8,
    Y > 1,
    X1 is X+1,
    Y1 is Y-1,
    other_symbol(S,OS),
    placed(Board,OS,X1,Y1),!.
% cappedDL(Board,S,X,Y) is true if on the board Board for player with symbol S, the opposing player's disc is placed more than 1 space to the lower-left.
cappedDL(Board,S,X,Y) :-
    X < 7,
    Y > 2,
    X1 is X+1,
    Y1 is Y-1,
    placed(Board,S,X1,Y1),
    cappedDL(Board,S,X1,Y1).

% The board is capped in the lower right diagonal direction.
% cappedDR(Board,S,X,Y) is true if on the board Board for player with symbol S, the opposing player's disc is placed 1 space to the lower-right.
cappedDR(Board,S,X,Y) :-
    X < 8,
    Y < 8,
    X1 is X+1,
    Y1 is Y+1,
    other_symbol(S,OS),
    placed(Board,OS,X1,Y1),!.
% cappedDR(Board,S,X,Y) is true if on the board Board for player with symbol S, the opposing player's disc is placed more than 1 space to the lower-right.
cappedDR(Board,S,X,Y) :-
    X < 7,
    Y < 7,
    X1 is X+1,
    Y1 is Y+1,
    placed(Board,S,X1,Y1),
    cappedDR(Board,S,X1,Y1).






















