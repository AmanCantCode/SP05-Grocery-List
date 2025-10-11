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
        debugPrint("Supabase sign-up error: $e");
      }
    }
  }

  //login with google pressed
  void googleLogin() async {
    try {
      await authService.googleSignIn();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Google Sign-In Error: ${e.toString()}")),
        );
      }
      debugPrint("Google Sign-In error: $e");
    }
  }

  //UI for login page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFAAEA61),
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(30.0),
          children: [
            //spacing
            SizedBox(height: 50),

            Image.asset('assets/images/Logo.png',
              width: 100,
              height: 100,
            ),

            //spacing
            SizedBox(height: 20),
        
            const Text(
              "Shared lists, fewer trips.",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
              textAlign: TextAlign.center,
            ),

            //spacing
            SizedBox(height: 60),

            // email
            SizedBox(
              width: double.infinity,
              child: TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Email",
                  hintStyle: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: Color(0xFF1B1B1B),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            SizedBox(height: 15),

            // password
            SizedBox(
              width: double.infinity,
              child: TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Password",
                  hintStyle: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    color: Color(0xFF1B1B1B),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            //spacing
            SizedBox(height: 15),

            // login button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B1B1B),
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Sign in",
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Inter',
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            //spacing
            SizedBox(height: 15),

            // login with google button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: googleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Continue with Google",
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Inter',
                        color: Color(0xFF1B1B1B),
                      ),
                    ),
                    Image.asset(
                        'assets/images/google-logo.png',
                      width: 50,
                      height: 50,
                    )
                  ]
                ),
              ),
            ),

            //spacing
            SizedBox(height: 30,),

            //direct user to forgot password option
            Text("Forgot Password?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontFamily: 'Inter',
              ),
            ),

            //spacing
            SizedBox(height: 5,),
            //direct user to register page
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Don't have an account? ",
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Inter',
                  ),
                ),
                GestureDetector(
                    onTap: () => Navigator.push(
                        context, MaterialPageRoute(builder: (context) => const RegisterPage(),
                    )),
                    child:
                    Text("Register",
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Inter',
                        color: Colors.white
                      ),)
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
