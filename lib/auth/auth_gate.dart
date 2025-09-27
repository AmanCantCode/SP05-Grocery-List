//This file allows us to continuously listen to auth state changes
// if un_auth : login page
// if auth : main (home) page
import 'package:flutter/material.dart';
import 'package:sp_grocery_list/pages/homepage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../pages/login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    //listen to auth state changes
    return StreamBuilder(
      stream: Supabase.instance.client.auth.onAuthStateChange,

      //build appropriate page based on auth state
      builder: (context, snapshot){
        if (snapshot.connectionState == ConnectionState.waiting){
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        //check for current valid session
        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null){
          return Homepage(); //change later if needed
        }
        else{
          return LoginPage();
        }
      },
    );
  }
}
