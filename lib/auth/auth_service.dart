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