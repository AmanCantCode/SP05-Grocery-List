import 'package:flutter/material.dart';
import 'package:sp_grocery_list/auth/auth_service.dart';
import 'package:sp_grocery_list/pages/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  //get auth service
  final authService = AuthService();

  //text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  //login button pressed
  void login() async {
    //prepare data
    final email = _emailController.text;
    final password = _passwordController.text;

    //attempt to login
    try{
      await authService.signInWithEmailPassword(email, password);
    }
    catch(e){
      if (mounted){
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  //UI for login page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(15.0),
        children: [
          //remove later
          SizedBox(height: 150,),

          //email
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: "Email"),
          ),

          //password
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: "Password"),
          ),

          //login button
          ElevatedButton(
              onPressed: login,
              child: const Text(
                "Sign in"
              )
          ),

          //direct user to forgot password option
          Text("Forgot Password?"),

          //direct user to register page
          Row(
            children: [
              Text("Don't have an account? "),
              GestureDetector(
                  onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (context) => const RegisterPage(),
                  )),
                  child: Text(
                      "Register")
              ),
            ],
          ),
        ],
      ),
    );
  }
}
