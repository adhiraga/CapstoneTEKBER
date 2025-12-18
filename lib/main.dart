import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'models/game_state.dart';
import 'screens/auth_screen.dart';
import 'screens/leaderboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    if (e.toString().contains('duplicate-app')) {
      print('Firebase already initialized');
    } else {
      rethrow;
    }
  }
  
  runApp(const TicTacTooApp());
}

enum GameMode { ai, multiplayer }

class TicTacTooApp extends StatelessWidget {
  const TicTacTooApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Tic Tac Toe',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.grey,
          brightness: Brightness.light,
        ),
      ),
      home: const AuthScreen(),
      routes: {
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Tic Tac Toe',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard, color: Colors.blue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LeaderboardScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () {
              FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed('/auth');
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            const Text(
              'Select Game Mode',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 60),
            // AI Mode Button
            GameModeButton(
              title: 'Play vs AI',
              subtitle: 'Play against the computer',
              icon: Icons.computer,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const GameScreen(gameMode: GameMode.ai),
                  ),
                );
              },
            ),
            const SizedBox(height: 30),
            // Multiplayer Mode Button
            GameModeButton(
              title: 'Multiplayer',
              subtitle: 'Play with another player',
              icon: Icons.people,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PlayerNamesScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }
}

class GameModeButton extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onPressed;

  const GameModeButton({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<GameModeButton> createState() => _GameModeButtonState();
}

class _GameModeButtonState extends State<GameModeButton> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() {
          isHovered = true;
        });
      },
      onExit: (_) {
        setState(() {
          isHovered = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 300,
        decoration: BoxDecoration(
          color: isHovered ? Colors.grey[200] : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (isHovered)
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              child: Column(
                children: [
                  Icon(
                    widget.icon,
                    size: 48,
                    color: Colors.blue[700],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PlayerNamesScreen extends StatefulWidget {
  const PlayerNamesScreen({Key? key}) : super(key: key);

  @override
  State<PlayerNamesScreen> createState() => _PlayerNamesScreenState();
}

class _PlayerNamesScreenState extends State<PlayerNamesScreen> {
  final TextEditingController _player1Controller = TextEditingController();
  final TextEditingController _player2Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _player1Controller.text = 'Player 1';
    _player2Controller.text = 'Player 2';
  }

  @override
  void dispose() {
    _player1Controller.dispose();
    _player2Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tic Tac Toe',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Enter Player Names',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 48),
              // Player 1 Input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Player 1 (X)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _player1Controller,
                      decoration: InputDecoration(
                        hintText: 'Enter name',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey[300]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.blue[700]!,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Player 2 Input
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Player 2 (O)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.red[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _player2Controller,
                      decoration: InputDecoration(
                        hintText: 'Enter name',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey[300]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.red[700]!,
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),

              ElevatedButton(
                onPressed: () {
                  final player1Name = _player1Controller.text.isEmpty
                      ? 'Player 1'
                      : _player1Controller.text;
                  final player2Name = _player2Controller.text.isEmpty
                      ? 'Player 2'
                      : _player2Controller.text;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GameScreen(
                        gameMode: GameMode.multiplayer,
                        player1Name: player1Name,
                        player2Name: player2Name,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                ),
                child: const Text(
                  'Start Game',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  final GameMode gameMode;
  final String? player1Name;
  final String? player2Name;

  const GameScreen({
    Key? key,
    required this.gameMode,
    this.player1Name,
    this.player2Name,
  }) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState gameState;
  bool isAIThinking = false;

  @override
  void initState() {
    super.initState();
    gameState = GameState();
  }

  void handleCellTap(int index) {
    if (widget.gameMode == GameMode.ai) {
      _handleAIModeTap(index);
    } else {
      _handleMultiplayerTap(index);
    }
  }

  void _handleAIModeTap(int index) {
    if (!gameState.gameOver && 
        gameState.currentPlayer == Player.human &&
        gameState.board[index] == Player.empty &&
        !isAIThinking) {
      
      // Human move
      gameState.makeMove(index, Player.human);
      
      if (gameState.gameOver) {
        setState(() {});
        _updateAIGameResult();
        return;
      }
      
      isAIThinking = true;
      setState(() {});
      
      Future.microtask(() {
        if (!mounted || gameState.gameOver) return;
        
        int? aiMove = gameState.getAIMove();
        if (aiMove != null && mounted) {
          gameState.makeMove(aiMove, Player.ai);
          isAIThinking = false;
          if (mounted) {
            setState(() {});
            if (gameState.gameOver) {
              _updateAIGameResult();
            }
          }
        }
      });
    }
  }

  void _handleMultiplayerTap(int index) {
    if (!gameState.gameOver && gameState.board[index] == Player.empty) {
      setState(() {
        gameState.makeMove(index, gameState.currentPlayer);
        if (gameState.gameOver) {
          _updateMultiplayerGameResult();
        }
      });
    }
  }

  void resetGame() {
    setState(() {
      gameState.resetGame();
      isAIThinking = false;
    });
  }

  void _updateAIGameResult() {
    _saveAIResult();
  }
  
  Future<void> _saveAIResult() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      if (gameState.winner == Player.human) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({'aiWins': FieldValue.increment(1)});
      }
    } catch (e) {
      debugPrint('Error updating AI result: $e');
    }
  }

  void _updateMultiplayerGameResult() {
    _saveMultiplayerResult();
  }
  
  Future<void> _saveMultiplayerResult() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'multiplayerWins': FieldValue.increment(1)});
    } catch (e) {
      debugPrint('Error updating multiplayer result: $e');
    }
  }

  void backToMenu() {
    if (widget.gameMode == GameMode.ai) {
      _showAIBackDialog();
    } else {
      _showMultiplayerBackDialog();
    }
  }

  void _showAIBackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Exit Game?',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: const Text(
          'Are you sure you want to leave the game? Your progress will be lost.',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'Leave Game',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMultiplayerBackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Exit Game?',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: const Text(
          'Where would you like to go?',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Keep Playing',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'Back to Names',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text(
              'Back to Home',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: backToMenu,
        ),
        title: const Text(
          'Tic Tac Toe',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Mode indicator
            if (widget.gameMode == GameMode.ai)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '🤖 Playing vs AI',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '👥 Multiplayer Mode',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: GameBoard(
                gameState: gameState,
                onCellTap: handleCellTap,
              ),
            ),
            const SizedBox(height: 32),
            GameStatus(
              gameState: gameState,
              gameMode: widget.gameMode,
              player1Name: widget.player1Name,
              player2Name: widget.player2Name,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                // Save game result before resetting
                if (gameState.gameOver) {
                  if (widget.gameMode == GameMode.ai) {
                    _updateAIGameResult();
                  } else {
                    if (gameState.winner == Player.human) {
                      _updateMultiplayerGameResult();
                    } else if (gameState.winner == Player.ai) {
                      // Player 2 won, update player 2's wins
                      // For now, we'll skip this - would need player2 Firebase info
                    }
                  }
                }
                resetGame();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('New Game'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 48),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Attribution(),
            ),
          ],
        ),
      ),
    );
  }
}

class GameBoard extends StatelessWidget {
  final GameState gameState;
  final Function(int) onCellTap;

  const GameBoard({
    Key? key,
    required this.gameState,
    required this.onCellTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        return GameCell(
          player: gameState.board[index],
          onTap: () => onCellTap(index),
        );
      },
    );
  }
}

class GameCell extends StatefulWidget {
  final Player player;
  final VoidCallback onTap;

  const GameCell({
    Key? key,
    required this.player,
    required this.onTap,
  }) : super(key: key);

  @override
  State<GameCell> createState() => _GameCellState();
}

class _GameCellState extends State<GameCell> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isHovered ? Colors.grey[200] : Colors.grey[100],
            border: Border.all(
              color: isHovered ? Colors.grey[400]! : Colors.grey[300]!,
              width: isHovered ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              widget.player == Player.human
                  ? 'X'
                  : widget.player == Player.ai
                      ? 'O'
                      : '',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: widget.player == Player.human
                    ? Colors.blue[700]
                    : Colors.red[700],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GameStatus extends StatelessWidget {
  final GameState gameState;
  final GameMode gameMode;
  final String? player1Name;
  final String? player2Name;

  const GameStatus({
    Key? key,
    required this.gameState,
    required this.gameMode,
    this.player1Name,
    this.player2Name,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String statusText;
    Color statusColor;

    if (gameMode == GameMode.ai) {
      if (gameState.gameOver) {
        if (gameState.winner == Player.human) {
          statusText = 'You Win!';
          statusColor = Colors.green[700]!;
        } else if (gameState.winner == Player.ai) {
          statusText = 'AI Wins!';
          statusColor = Colors.red[700]!;
        } else {
          statusText = "It's a Draw!";
          statusColor = Colors.orange[700]!;
        }
      } else {
        statusText = gameState.currentPlayer == Player.human
            ? 'Your Turn'
            : 'AI Playing...';
        statusColor = Colors.grey[700]!;
      }
    } else {
      // Multiplayer mode
      final p1Name = player1Name ?? 'Player 1';
      final p2Name = player2Name ?? 'Player 2';

      if (gameState.gameOver) {
        if (gameState.winner == Player.human) {
          statusText = '$p1Name Wins!';
          statusColor = Colors.green[700]!;
        } else if (gameState.winner == Player.ai) {
          statusText = '$p2Name Wins!';
          statusColor = Colors.green[700]!;
        } else {
          statusText = "It's a Draw!";
          statusColor = Colors.orange[700]!;
        }
      } else {
        final currentPlayerName = gameState.currentPlayer == Player.human ? p1Name : p2Name;
        statusText = "$currentPlayerName's Turn";
        statusColor = Colors.grey[700]!;
      }
    }

    return Text(
      statusText,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: statusColor,
      ),
    );
  }
}

class Attribution extends StatelessWidget {
  const Attribution({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Group 10',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Muhammad Abyansyah Putra Dewanto (5026231052)',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        Text(
          'Ida Bagus Adhiraga Yudhistira (5026231120)',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
