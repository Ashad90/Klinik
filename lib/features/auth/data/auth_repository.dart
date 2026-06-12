import 'package:firebase_auth/firebase_auth.dart';

/// Accès Firebase Auth (email/mot de passe). La persistance du token est réglée
/// sur LOCAL dans `main.dart` — le token survit à la fermeture de l'app.
class AuthRepository {
  final FirebaseAuth _auth;
  const AuthRepository(this._auth);

  User? get currentUser => _auth.currentUser;
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<User> signUp({required String email, required String password}) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return cred.user!;
  }

  Future<User> signIn({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return cred.user!;
  }

  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  Future<void> signOut() => _auth.signOut();
}
