import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService{
  final SupabaseClient _supabase = Supabase.instance.client;

  //sign in with email and password
  Future<AuthResponse> signInWithEmailPassword(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,

    );
  }

  //sign up with email and password
  Future<AuthResponse> signUpWithEmailPassword(String email, String password, String name) async {
    return await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'display_name': name,
        }
    );
  }

  //sign in with google
  Future<AuthResponse> googleSignIn() async {
    const webClientId = '306185453783-eaovbknio249u4jtb1f58as5jrm78729.apps.googleusercontent.com';
    const iosClientId = '306185453783-01eio6sq0nlghlh07jltm6c51v7javbf.apps.googleusercontent.com';

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: iosClientId,
      serverClientId: webClientId,
    );
    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser!.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null) {
      throw 'No Access Token found.';
    }
    if (idToken == null) {
      throw 'No ID Token found.';
    }

    return _supabase.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  // Update display name
  Future<void> updateDisplayName(String name) async {
    final response = await _supabase.auth.updateUser(
      UserAttributes(data: {'full_name': name}),
    );

    if (response.user == null) {
      throw Exception("Failed to update display name");
    }
  }

  //sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  //get user email
  String? getCurrentUserEmail() {
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }

  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }
}