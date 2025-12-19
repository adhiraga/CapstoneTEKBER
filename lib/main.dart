import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'models/game_state.dart';
import 'screens/auth_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'services/sound_service.dart';

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
  const TicTacTooApp({super.key});

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
        '/auth': (context) => const AuthScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late bool _soundEnabled;
  String _username = '';
  int _totalGames = 0;
  int _totalWins = 0;

  @override
  void initState() {
    super.initState();
    _soundEnabled = SoundService().soundEnabled;
    _loadUserStats();
  }

  Future<void> _loadUserStats() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();
        
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          setState(() {
            _username = data['username'] ?? 'Player';
            _totalWins = (data['aiWins'] ?? 0) as int;
            final multiplayerGames = (data['multiplayerGamesPlayed'] ?? 0) as int;
            _totalGames = _totalWins + multiplayerGames;
          });
        }
      } catch (e) {
        print('Error loading user stats: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Icons Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      _soundEnabled ? Icons.volume_up : Icons.volume_off,
                      color: _soundEnabled ? Colors.green : Colors.grey,
                      size: 28,
                    ),
                    onPressed: () {
                      setState(() {
                        SoundService().toggleSound();
                        _soundEnabled = SoundService().soundEnabled;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.red,
                      size: 28,
                    ),
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      Navigator.of(context).pushReplacementNamed('/auth');
                    },
                  ),
                ],
              ),
            ),
            
            // Main Content
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Title with Multiple Colors
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Tic ',
                            style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                              letterSpacing: 2.5,
                              shadows: [
                                Shadow(
                                  offset: const Offset(2, 2),
                                  blurRadius: 4,
                                  color: Colors.black.withAlpha((0.2 * 255).round()),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Tac ',
                            style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[800],
                              letterSpacing: 2.5,
                              shadows: [
                                Shadow(
                                  offset: const Offset(2, 2),
                                  blurRadius: 4,
                                  color: Colors.black.withAlpha((0.2 * 255).round()),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Toe',
                            style: TextStyle(
                              fontSize: 52,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal[700],
                              letterSpacing: 2.5,
                              shadows: [
                                Shadow(
                                  offset: const Offset(2, 2),
                                  blurRadius: 4,
                                  color: Colors.black.withAlpha((0.2 * 255).round()),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Welcome Message
                      Text(
                        'Welcome, $_username',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Stats Box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.blue[100]!,
                              Colors.blue[50]!,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Your Stats',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      '$_totalGames',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Games',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      '$_totalWins',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Wins',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      // Buttons
                      _buildMenuButton(
                        context,
                        'Versus A.I',
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const GameScreen(gameMode: GameMode.ai),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildMenuButton(
                        context,
                        'Multiplayer',
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PlayerNamesScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildMenuButton(
                        context,
                        'Leaderboard',
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LeaderboardScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, VoidCallback onPressed) {
    IconData icon;
    switch (title) {
      case 'Versus A.I':
        icon = Icons.computer;
        break;
      case 'Multiplayer':
        icon = Icons.people;
        break;
      case 'Leaderboard':
        icon = Icons.leaderboard;
        break;
      default:
        icon = Icons.games;
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[600],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
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

  const GameModeButton({super.key, required this.title, required this.subtitle, required this.icon, required this.onPressed});

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
                color: Colors.grey.withAlpha((0.3 * 255).round()),
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
  const PlayerNamesScreen({super.key});

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

  const GameScreen({super.key, required this.gameMode, this.player1Name, this.player2Name});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameState gameState;
  bool isAIThinking = false;
  bool isWinClaimed = false;

  @override
  void initState() {
    super.initState();
    gameState = GameState();
    
    // Check authentication for AI mode
    if (widget.gameMode == GameMode.ai) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkAuthenticationForAIMode();
      });
    }
  }
  
  Future<void> _checkAuthenticationForAIMode() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    
    if (currentUser == null) {
      print('INFO: User not logged in, showing login prompt');
      
      if (!mounted) return;
      
      final shouldLogin = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Login Required'),
          content: const Text(
            'You need to be logged in to play vs AI and save your progress to the leaderboard.\n\nWould you like to login now?'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Go Back'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Login'),
            ),
          ],
        ),
      );
      
      if (shouldLogin == true) {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed('/auth');
        }
      } else {
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } else {
      print('INFO: User logged in: ${currentUser.uid}');
    }
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
      isWinClaimed = false;
    });
  }

  void _updateAIGameResult() {
    if (gameState.winner != null) {
      SoundService().playWinSound();
    } else if (gameState.gameOver) {
      SoundService().playDrawSound();
    }
  }
  
  Future<void> _claimWin() async {
    if (isWinClaimed) return;
    
    setState(() {
      isWinClaimed = true;
    });
    
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      print('DEBUG: Checking auth state...');
      print('DEBUG: Current user: ${currentUser?.uid}');
      print('DEBUG: User email: ${currentUser?.email}');
      print('DEBUG: Is anonymous: ${currentUser?.isAnonymous}');
      
      if (currentUser == null) {
        print('ERROR: No user logged in');
        setState(() {
          isWinClaimed = false;
        });
        
        // Show dialog to ask user to login
        if (mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Login Required'),
                content: const Text(
                  'You need to be logged in to save your progress.\n\nWould you like to login now?',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pushReplacementNamed('/auth');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Login'),
                  ),
                ],
              );
            },
          );
        }
        return;
      }

      print('Claiming win for user: ${currentUser.uid}');
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'aiWins': FieldValue.increment(1)});
      print('Win claimed successfully!');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Congratulations! Progress +1'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error claiming win: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to claim win: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        isWinClaimed = false;
      });
    }
  }

  void _updateMultiplayerGameResult() {
    if (gameState.winner != null) {
      SoundService().playWinSound();
    } else if (gameState.gameOver) {
      SoundService().playDrawSound();
    }
    _saveMultiplayerResult();
  }
  
  Future<void> _saveMultiplayerResult() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) return;

      // Increment games played count when game is completed
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .update({'multiplayerGamesPlayed': FieldValue.increment(1)});
      
      print('Multiplayer game completed and counted');
    } catch (e) {
      print('Error saving result: $e');
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
      body: SingleChildScrollView(
        child: Column(
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
            if (widget.gameMode == GameMode.ai && 
                gameState.gameOver && 
                gameState.winner == Player.human && 
                !isWinClaimed)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ElevatedButton.icon(
                  onPressed: _claimWin,
                  icon: const Icon(Icons.emoji_events),
                  label: const Text('Claim Your Win!'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ),
            ElevatedButton.icon(
              onPressed: () {
                if (gameState.gameOver) {
                  if (widget.gameMode == GameMode.multiplayer) {
                    if (gameState.winner == Player.human) {
                      _updateMultiplayerGameResult();
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
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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

  const GameBoard({super.key, required this.gameState, required this.onCellTap});

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

  const GameCell({super.key, required this.player, required this.onTap});

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

  const GameStatus({super.key, required this.gameState, required this.gameMode, this.player1Name, this.player2Name});

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
  const Attribution({super.key});

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
