import 'package:flutter/material.dart';
import 'package:sp_grocery_list/auth/auth_service.dart';

class UserAccountPage extends StatefulWidget {
  UserAccountPage({super.key});

  @override
  State<UserAccountPage> createState() => _UserAccountPageState();
}

class _UserAccountPageState extends State<UserAccountPage> {
  @override

  //get auth service
  final authService = AuthService();

  //logout
  void logout() async {
    await authService.signOut();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'This is the user account page.',
              style: TextStyle(
                fontSize: 25,
              ),
              textAlign: TextAlign.center,
            ),

            //placeholder logout button
            Container(
              color: Color(0xFFAAEA61),
              child: IconButton(
                icon: Icon(Icons.logout),
                onPressed: logout,
              ),
            ),
          ],
        ),

      ),
    );
  }
}
