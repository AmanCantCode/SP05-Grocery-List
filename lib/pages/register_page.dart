import 'package:flutter/material.dart';
import 'package:sp_grocery_list/pages/login_page.dart';
import '../auth/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {

  //get auth service
  final authService = AuthService();

  //text controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();


  //register button pressed
  void signUp() async {
    //prepare data
    final name = _nameController.text;
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    //check to see if passwords match
    if (password != confirmPassword){
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Passwords don't match.")));
      return;
    }

    //attempt registering user
    try{
      await authService.signUpWithEmailPassword(email, password, name);

      //pop this page after user registers
      Navigator.pop(context);
    }
    catch(e){
      if (mounted){
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
        debugPrint("Supabase sign-up error: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(15.0),
        children: [
          //remove later
          SizedBox(height: 150,),
          //name
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: "Name"),
          ),

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

          //confirm password
          TextField(
            controller: _confirmPasswordController,
            decoration: const InputDecoration(labelText: "Confirm Password"),
          ),

          //login button
          ElevatedButton(
              onPressed: signUp,
              child: const Text(
                  "Sign up"
              )
          ),

          //direct user to register page
          Row(
            children: [
              Text("Already have an account? "),
              GestureDetector(
                  onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (context) => const LoginPage(),
                  )),
                  child: Text(
                      "Login")
              ),
            ],
          ),
        ],
      ),
    );
  }
}
