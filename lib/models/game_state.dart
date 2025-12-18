enum Player { human, ai, empty }

class GameState {
  late List<Player> board;
  late Player currentPlayer;
  bool gameOver = false;
  Player? winner;
  int aiWins = 0;
  int humanWins = 0;

  static const List<List<int>> winPatterns = [
    [0, 1, 2],
    [3, 4, 5],
    [6, 7, 8],
    [0, 3, 6],
    [1, 4, 7],
    [2, 5, 8],
    [0, 4, 8],
    [2, 4, 6]
  ];

  final Map<String, int> _minimaxCache = {};

  GameState() {
    resetGame();
  }

  void resetGame() {
    board = List.filled(9, Player.empty);
    currentPlayer = Player.human;
    gameOver = false;
    winner = null;
    _minimaxCache.clear();
  }

  bool isValidMove(int index) {
    return board[index] == Player.empty && !gameOver;
  }

  void makeMove(int index, Player player) {
    if (isValidMove(index)) {
      board[index] = player;
      checkGameStatus();
      if (!gameOver) {
        currentPlayer = player == Player.human ? Player.ai : Player.human;
      }
    }
  }

  void checkGameStatus() {
    for (var pattern in winPatterns) {
      if (board[pattern[0]] != Player.empty &&
          board[pattern[0]] == board[pattern[1]] &&
          board[pattern[1]] == board[pattern[2]]) {
        winner = board[pattern[0]];
        gameOver = true;
        if (winner == Player.ai) {
          aiWins++;
        } else if (winner == Player.human) {
          humanWins++;
        }
        return;
      }
    }

    if (!board.contains(Player.empty)) {
      gameOver = true;
    }
  }

  int? getAIMove() {
    for (int i = 0; i < 9; i++) {
    for (int i = 0; i < 9; i++) {
      if (board[i] == Player.empty) {
        board[i] = Player.ai;
        if (_checkWinner() == Player.ai) {
          board[i] = Player.empty;
          return i;
        }
        board[i] = Player.empty;
      }
    }
    
    for (int i = 0; i < 9; i++) {
      if (board[i] == Player.empty) {
        board[i] = Player.human;
        if (_checkWinner() == Player.human) {
          board[i] = Player.empty;
          return i;
        }
        board[i] = Player.empty;
      }
    }
    
    if (board[4] == Player.empty) return 4;
    
    final corners = [0, 2, 6, 8];
    for (var c in corners) {
      if (board[c] == Player.empty) return c;
    }
    
    for (int i = 0; i < 9; i++) {
      if (board[i] == Player.empty) return i;
    }
    
    return null;
  }
  
  Player? _checkWinner() {
    for (var pattern in winPatterns) {
      if (board[pattern[0]] != Player.empty &&
          board[pattern[0]] == board[pattern[1]] &&
          board[pattern[1]] == board[pattern[2]]) {
        return board[pattern[0]];
      }
    }
    return null;
  }

  int minimax(int depth, bool isMaximizing, {int alpha = -9999, int beta = 9999}) {
    for (var pattern in winPatterns) {
      if (board[pattern[0]] == Player.ai &&
          board[pattern[0]] == board[pattern[1]] &&
          board[pattern[1]] == board[pattern[2]]) {
        return 10 - depth;
      }
      if (board[pattern[0]] == Player.human &&
          board[pattern[0]] == board[pattern[1]] &&
          board[pattern[1]] == board[pattern[2]]) {
        return depth - 10;
      }
    }

    if (!board.contains(Player.empty)) {
      return 0;
    }

    if (isMaximizing) {
      int bestScore = -9999;
      for (int i = 0; i < 9; i++) {
        if (board[i] == Player.empty) {
          board[i] = Player.ai;
          int score = minimax(depth + 1, false, alpha: alpha, beta: beta);
          board[i] = Player.empty;
          bestScore = bestScore > score ? bestScore : score;
          alpha = alpha > bestScore ? alpha : bestScore;
          if (beta <= alpha) break;
        }
      }
      return bestScore;
    } else {
      int bestScore = 9999;
      for (int i = 0; i < 9; i++) {
        if (board[i] == Player.empty) {
          board[i] = Player.human;
          int score = minimax(depth + 1, true, alpha: alpha, beta: beta);
          board[i] = Player.empty;
          bestScore = bestScore < score ? bestScore : score;
          beta = beta < bestScore ? beta : bestScore;
          if (beta <= alpha) break;
        }
      }
      return bestScore;
    }
  }
}
