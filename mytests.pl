:- multifile puzzle/4.

% Tests snakeConnected. The first row hint and countNeighbours can be satisfied by a closed
% loop in the top 3 rows, and a disjoints straight path between the heads at the bottom corners.
% A solver without snakeConnected accepts this but a correct solver rejects it
% and finds a single connected path instead.
puzzle(myCycle, [5,-1,-1,-1,-1], [-1,-1,-1,-1,-1], [[-1,-1,-1,-1,-1], [-1,-1,-1,-1,-1], [-1,-1,-1,-1,-1], [-1,-1,-1,-1,-1], [1,-1,-1,-1,1]]).

% Tests that pre-filled empty cells are respected. The 0 at second cell of the first row
% blocks the direct path along the top row, forcing the snake to go through
% rows below. A solver that ignores pre-filled cells would find an extra
% invalid shortcut solution.
puzzle(myEmpty, [-1,-1,-1], [-1,-1,-1,-1], [[ 1, 0,-1, 1], [-1,-1,-1,-1] , [-1,-1,-1,-1]]).

% Tests checkRowHints. Without the row hint at the first row, there are three valid
% paths connecting the heads. The hint forces the snake to fill the entire
% top row, leaving only one valid solution.
puzzle(myHints, [3,-1], [-1,-1,-1], [[ 1,-1,-1], [-1,-1, 1]]).
