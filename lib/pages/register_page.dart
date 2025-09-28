// import 'package:flutter/material.dart';
// import 'package:sp_grocery_list/pages/login_page.dart';
// import '../auth/auth_service.dart';
//
// class RegisterPage extends StatefulWidget {
//   const RegisterPage({super.key});
//
//   @override
//   State<RegisterPage> createState() => _RegisterPageState();
// }
//
// class _RegisterPageState extends State<RegisterPage> {
//
//   //get auth service
//   final authService = AuthService();
//
//   //text controllers
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();
//
//
//   //register button pressed
//   void signUp() async {
//     //prepare data
//     final name = _nameController.text;
//     final email = _emailController.text;
//     final password = _passwordController.text;
//     final confirmPassword = _confirmPasswordController.text;
//
//     //check to see if passwords match
//     if (password != confirmPassword){
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text("Passwords don't match.")));
//       return;
//     }
//
//     //attempt registering user
//     try{
//       await authService.signUpWithEmailPassword(email, password, name);
//
//       //pop this page after user registers
//       Navigator.pop(context);
//     }
//     catch(e){
//       if (mounted){
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text("Error: $e")));
//         debugPrint("Supabase sign-up error: $e");
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: ListView(
//         padding: EdgeInsets.all(15.0),
//         children: [
//           //remove later
//           SizedBox(height: 150,),
//           //name
//           TextField(
//             controller: _nameController,
//             decoration: const InputDecoration(labelText: "Name"),
//           ),
//
//           //email
//           TextField(
//             controller: _emailController,
//             decoration: const InputDecoration(labelText: "Email"),
//           ),
//
//           //password
//           TextField(
//             controller: _passwordController,
//             decoration: const InputDecoration(labelText: "Password"),
//           ),
//
//           //confirm password
//           TextField(
//             controller: _confirmPasswordController,
//             decoration: const InputDecoration(labelText: "Confirm Password"),
//           ),
//
//           //login button
//           ElevatedButton(
//               onPressed: signUp,
//               child: const Text(
//                   "Sign up"
//               )
//           ),
//
//           //direct user to register page
//           Row(
//             children: [
//               Text("Already have an account? "),
//               GestureDetector(
//                   onTap: () => Navigator.push(
//                       context, MaterialPageRoute(builder: (context) => const LoginPage(),
//                   )),
//                   child: Text(
//                       "Login")
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

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
      backgroundColor: const Color(0xFFAAEA61),
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(30.0),
          children: [
            //remove later
            SizedBox(height: 150,),

            const Text(
              "Start tracking together, now",
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 35,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
              textAlign: TextAlign.left,
            ),

            //spacing
            SizedBox(height: 30),

            //name
            SizedBox(
              width: double.infinity,
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Name",
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

            SizedBox(height: 15),

            // confirm password
            SizedBox(
              width: double.infinity,
              child: TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Confirm Password",
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
            SizedBox(height: 30),

            // login button (Sign up)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B1B1B),
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Sign up",
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Inter',
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            //spacing
            SizedBox(height: 30,),

            //direct user to login page
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Already have an account? ",
                  style: TextStyle(
                    fontSize: 15,
                    fontFamily: 'Inter',
                  ),
                ),
                GestureDetector(
                    onTap: () => Navigator.push(
                        context, MaterialPageRoute(builder: (context) => const LoginPage(),
                    )),
                    child:
                    Text("Login",
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