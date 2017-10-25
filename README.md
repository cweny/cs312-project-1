# cs312-project-1
UBC CS 312 Fall 2017 Project 1 
Authors: Juliane Yamasaki, Nicholas Chan, Carlos Wen

### What is the problem?
Implement an interactive, classic game of Othello in Prolog.

The game is played on an 8 x 8 board, 64 discs and two players. The player must place a disc that outflanks the opposing player's discs, this flips the outflanked\ disc(s) to the player's color. The winner of the game is the player with the majority of discs of their color on the board.

The program will automatically enforce Othello's ruleset, which can be found here, http://www.hannu.se/games/othello/rules.htm.

### What is the something extra?
Our game will allow the player to choose between two different playing modes, playing against another human player or playing against an AI-based computer player, or watch an AI vs. AI game.

In the player vs. player mode, both players will be prompted to choose the coordinates of the disc they want to place. The game continues until one player has no moves left or the board is full.

In the player vs. computer mode, the player will be prompted to choose the coordinates of the disc they want to place. Based on the move made by the player the computer will play the "best move" predicted. Our computer AI will decide a move based on the number of discs they can flip of their own color. This decision will be made according to the Minimax rule.The goal of Minimax is to minimize the maximum loss by calculating and comparing the "values" of possible moves. In our program, "values" refers to the number of the player's discs on the board after a move is made. The AI will then choose the move that maximizes player's values and minimizes it's own values. This page was used as reference, https://en.wikipedia.org/wiki/Minimax.

In the computer vs. computer mode the "player" can spectate a between two AI. The player can choose the strength for each AI, and how frequently they want to print out the moves. This was mostly implemented for debugging purposes, as manually inputting 60 moves to reach game over can be very tedious.

### What did we learn from doing this?
Othello's list structure simplifies coding somewhat, but comes at a cost with regards to runtime and debugging. For example, to check a point on the 8 x 8 Othello board, we needed to iterate through two lists, as opposed to accessing a traditional array. This becomes a major concern when the number of boards grows exponentially with search depth. As for debugging, the trace function on SWI is not equipped to print out long lists as arguments, and often truncates them. This makes detecting undesirable behavior more difficult, along with making the console output much less readable.

With that said, prolog ran remarkably quickly, calculating on the order of 10^5 moves in a few seconds. Ultimately we found that our chief concern was memory rather than runtime.

We were able to implement a simple AI that, given a board state, could determine the move that would maximize its score. We then expanded the AI to look ahead multiple moves up to a given depth, and pick the best sequence. We immediately discovered that the AI would run out of memory extremely quickly, crashing in a few moves on depth 4 and not reaching the end of a game on depth 2. This was because we were searching all 64 possible squares at each step. We noticed that only moves along the 'border' of previously played moves could possibly be played, and by iterating on this instead we managed to make it to the end of depth 2 game. The AI still crashes after ~30 moves on depth 3, so we made a depth limiting function for demonstration purposes.

Unfortunately, the AI is completely ignorant of Othello strategy, such as taking the edges and corners, in that such moves are not prioritized over raw calculation. This is because we could not implement these features without extending the runtime beyond what was reasonable, without also requiring even more memory and causing the AI to crash even faster.

At a guess, prolog is better suited for more abstract calculations than it is for raw number crunching.