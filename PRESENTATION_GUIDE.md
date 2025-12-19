# 📋 Tic Tac Toe - Presentation Guide
**Jangan push file ini ke repository!**

---

## 🎯 Ringkasan Proyek
**Tic Tac Toe** adalah aplikasi game Flutter dengan fitur:
- Multiplayer & AI mode
- Firebase Authentication & Firestore database
- Leaderboard dengan highlight user aktif
- Sound effects & UI yang menarik

---

## 📂 File-File Penting yang Harus Dibahas

### 1. **lib/main.dart** - Home Screen & Game Logic
**Lokasi:** Lines 55-340 (HomeScreen), Lines 680-710 (_saveMultiplayerResult)

#### ✨ Yang Dibahas:

**A. Home Screen UI (Lines 62-174)**
```dart
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
}
```

**Penjelasan:**
- `initState()`: Load user stats dari Firestore saat pertama kali screen dibuka
- `_loadUserStats()`: Fetch username, AI wins, dan total multiplayer games dari Firestore
- Menggunakan `setState()` untuk update UI secara real-time

---

**B. Menu Button dengan Icon (Lines 294-330)**
```dart
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
```

**Penjelasan:**
- Dynamic icon berdasarkan button title menggunakan switch case
- Green button dengan white text dan icon
- Row layout untuk arrange icon + text secara horizontal

---

**C. Multiplayer Game Result Tracking (Lines 690-710)**
```dart
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
```

**Penjelasan:**
- Dipanggil setiap kali multiplayer game selesai (menang/kalah/draw)
- `FieldValue.increment(1)` untuk atomically increment counter di Firestore
- Tracks **total games played**, bukan hanya wins

---

### 2. **lib/screens/auth_screen.dart** - Authentication
**Lokasi:** Lines 38-180 (Registration & Login Logic)

#### ✨ Yang Dibahas:

**A. Registration Logic (Lines 38-118)**
```dart
Future<void> register() async {
  final username = usernameController.text.trim();
  final email = emailController.text.trim();
  final password = passwordController.text.trim();
  final confirmPassword = confirmPasswordController.text.trim();

  // Validasi fields
  if (username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
    showSnackBar('All fields are required');
    return;
  }

  if (!isValidEmail(email)) {
    showSnackBar('Please enter a valid email address');
    return;
  }

  if (!isValidPassword(password)) {
    showSnackBar('Password must be at least 6 characters');
    return;
  }

  if (password != confirmPassword) {
    showSnackBar('Passwords do not match');
    return;
  }

  setState(() => isLoading = true);

  try {
    // Check if username sudah exist
    final usernameQuery = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    if (usernameQuery.docs.isNotEmpty) {
      showSnackBar('Username is already taken');
      setState(() => isLoading = false);
      return;
    }

    // Create Firebase Auth user
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Save user data to Firestore
    await _firestore.collection('users').doc(userCredential.user!.uid).set({
      'username': username,
      'email': email,
      'password': password,
      'aiWins': 0,
      'multiplayerGamesPlayed': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    showSnackBar('Registration successful!');
    setState(() {
      isRegistering = false;
      usernameController.clear();
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
    });
  } on FirebaseAuthException catch (e) {
    showSnackBar(e.message ?? 'Registration failed');
  }

  setState(() => isLoading = false);
}
```

**Penjelasan:**
- **Validasi Input**: Email format & password minimum 6 karakter
- **Username Uniqueness**: Query Firestore untuk cek username belum dipakai
- **Dual Database**: 
  - Firebase Auth untuk authentication
  - Firestore untuk store user data (username, stats, etc)
- **Timestamp**: `serverTimestamp()` untuk accurate creation time

---

**B. Login Logic - IMPORTANT FIX (Lines 119-197)**
```dart
Future<void> login() async {
  final loginInput = usernameController.text.trim();
  final password = passwordController.text.trim();

  if (loginInput.isEmpty || password.isEmpty) {
    showSnackBar('Please fill in all fields');
    return;
  }

  setState(() => isLoading = true);

  try {
    String? email;
    String? storedPassword;

    // Check if input adalah email atau username
    if (loginInput.contains('@')) {
      email = loginInput;
    } else {
      // Query Firestore untuk cari user berdasarkan username
      final usernameQuery = await _firestore
          .collection('users')
          .where('username', isEqualTo: loginInput)
          .get();

      if (usernameQuery.docs.isEmpty) {
        showSnackBar('Username not found');
        setState(() => isLoading = false);
        return;
      }

      final userData = usernameQuery.docs.first.data();
      email = userData['email'];
      storedPassword = userData['password'];
    }

    // ✅ CRITICAL FIX: Always authenticate with Firebase Auth
    await _auth.signInWithEmailAndPassword(
      email: email!,
      password: password,
    );
    
    print('SUCCESS: User logged in: ${_auth.currentUser?.uid}');
    
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  } on FirebaseAuthException catch (e) {
    String message = '';
    if (e.code == 'user-not-found') {
      message = 'Email not found';
    } else if (e.code == 'wrong-password') {
      message = 'Wrong password';
    } else {
      message = e.message ?? 'Login failed';
    }
    showSnackBar(message);
  } catch (e) {
    showSnackBar('An error occurred: $e');
  }

  setState(() => isLoading = false);
}
```

**Penjelasan:**
- **Flexible Login**: Support login dengan email OR username
- **Username Resolution**: Jika input username, query Firestore untuk dapat email
- **CRITICAL**: Selalu call `signInWithEmailAndPassword()` untuk properly authenticate dengan Firebase
  - Ini memastikan `FirebaseAuth.currentUser` tidak null
  - Sebelumnya ada bug: username login langsung navigate tanpa Firebase Auth
- **Error Handling**: Specific error messages untuk different scenarios

---

### 3. **lib/screens/leaderboard_screen.dart** - Leaderboard with User Highlight
**Lokasi:** Lines 110-180 (AI Leaderboard), Lines 245-310 (Multiplayer Leaderboard)

#### ✨ Yang Dibahas:

**A. AI Leaderboard dengan User Highlight (Lines 119-175)**
```dart
return ListView.builder(
  itemCount: docs.length,
  itemBuilder: (context, index) {
    final doc = docs[index];
    final data = doc.data() as Map<String, dynamic>;
    final username = data['username'] ?? 'Unknown';
    final aiWins = data['aiWins'] ?? 0;
    final isCurrentUser = doc.id == _auth.currentUser?.uid;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.blue[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: isCurrentUser
            ? Border.all(color: Colors.blue[700]!, width: 2)
            : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isCurrentUser ? Colors.green[600] : Colors.blue[700],
            foregroundColor: Colors.white,
            child: Text('${index + 1}'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (isCurrentUser) ...<Widget>[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[600],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'You',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Text(
            '$aiWins wins',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  },
);
```

**Penjelasan:**
- **User Detection**: `isCurrentUser = doc.id == _auth.currentUser?.uid`
- **Conditional Styling**:
  - Background: Blue[50] (light) untuk current user, Grey[100] untuk lain
  - Border: Biru tebal (2px) hanya untuk current user
  - Avatar: Hijau untuk current user, Blue untuk lain
- **"You" Badge**: Conditional widget yang hanya muncul untuk current user
- **Spread Operator**: `if (isCurrentUser) ...<Widget>[...]` untuk add/remove widgets

---

**B. Multiplayer Leaderboard (Lines 254-310)**
```dart
return ListView.builder(
  itemCount: docs.length,
  itemBuilder: (context, index) {
    final doc = docs[index];
    final data = doc.data() as Map<String, dynamic>;
    final username = data['username'] ?? 'Unknown';
    final gamesPlayed = data['multiplayerGamesPlayed'] ?? 0;
    final isCurrentUser = doc.id == _auth.currentUser?.uid;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.red[50] : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: isCurrentUser
            ? Border.all(color: Colors.red[700]!, width: 2)
            : null,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isCurrentUser ? Colors.green[600] : Colors.red[700],
            foregroundColor: Colors.white,
            child: Text('${index + 1}'),
          ),
          // ... same structure as AI leaderboard
        ],
      ),
    );
  },
);
```

**Penjelasan:**
- **Metric Changed**: `multiplayerGamesPlayed` (total games) bukan `multiplayerWins` (hanya kemenangan)
- **Consistent Highlight**: Same highlight pattern seperti AI leaderboard
- **Color Theme**: Red[50] & Red[700] untuk multiplayer (vs Blue untuk AI)

---

### 4. **lib/main.dart** - Authentication Check Before AI Mode
**Lokasi:** Lines 467-530

#### ✨ Yang Dibahas:

**A. Authentication Check Method**
```dart
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
```

**Penjelasan:**
- **Dialog untuk login**: Muncul jika user belum login saat mau play AI mode
- **User choice**: Pilih untuk login atau kembali ke home
- **Navigation**: Jika login, push ke auth screen; jika batal, pop game screen
- **Mounted check**: `if (mounted)` untuk prevent error jika widget sudah disposed

---

## 🎨 UI/UX Improvements

### Title Styling dengan Gradient & Shadow
```dart
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
    // ... Tac & Toe dengan warna berbeda
  ],
)
```

**Fitur:**
- **Multi-color**: Tic (green), Tac (blue), Toe (teal) - gelap
- **Letter spacing**: 2.5 untuk elegant look
- **Drop shadow**: Offset (2,2) dengan blur radius 4

---

## 🗂️ Database Schema

### Firestore `users` Collection
```json
{
  "uid": "auto-generated-by-firebase",
  "username": "admin",
  "email": "admin@example.com",
  "password": "encrypted-by-firebase",
  "aiWins": 1,
  "multiplayerGamesPlayed": 2,
  "createdAt": "server-timestamp"
}
```

**Fields:**
- `aiWins`: Total kemenangan vs AI
- `multiplayerGamesPlayed`: Total games played di multiplayer (win/loss/draw semua dihitung)

---

## 🔑 Key Features to Highlight

1. **Flexible Authentication**: Support login dengan email atau username
2. **Real-time Stats**: Data loading dari Firestore saat home screen dibuka
3. **User Highlight**: Current user di highlight di leaderboard dengan border, background, dan badge
4. **Metric Change**: Multiplayer metric berubah dari "wins" ke "games played" (lebih fair)
5. **Auth Protection**: AI mode require login untuk save progress ke leaderboard
6. **Sound Management**: Toggle sound on/off di home screen
7. **Responsive UI**: Gradient title, icon buttons, clean layout

---

## 📝 Testing Checklist

Sebelum demo:
- [ ] Login dengan email ✓
- [ ] Login dengan username ✓
- [ ] Register akun baru ✓
- [ ] Play AI mode (harus login dulu) ✓
- [ ] Play multiplayer mode ✓
- [ ] Check leaderboard highlight ✓
- [ ] Verify stats update di home screen ✓
- [ ] Toggle sound on/off ✓
- [ ] Logout ✓

---

## 🚀 Technologies Used

- **Flutter 3.35.7**
- **Firebase Core 3.15.2**
- **Firebase Auth 5.7.0**
- **Cloud Firestore 5.6.12**
- **just_audio 0.9.46** (sound effects)
- **Material Design 3**

---

**Last Updated:** December 19, 2025
**Author:** GitHub Copilot + Student Development
