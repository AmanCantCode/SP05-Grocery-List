import 'package:flutter/material.dart';
import 'package:sp_grocery_list/auth/auth_service.dart';

class Homepage extends StatelessWidget {
  Homepage({super.key});

  //get auth service
  final authService = AuthService();

  //logout
  void logout() async {
    await authService.signOut();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Grocery List'),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              'This is the main page.',
              style: TextStyle(
                fontSize: 25,
              ),
            ),

            //placeholder logout button
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: logout,
            ),
          ],
        ),

      ),
    );
  }
}
