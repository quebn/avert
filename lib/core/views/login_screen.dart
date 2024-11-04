import "package:flutter/material.dart";
import "package:acqua/core/views/login_forms.dart";
import "package:acqua/core/utils.dart";
import "package:acqua/core/app.dart";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.title});

  final String title;

  @override
  State<StatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  bool signup = !App.hasUsers;

 @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(15.0),
            ),
            height: MediaQuery.sizeOf(context).height / 4,
            child: Center(
              child: Text(widget.title,
                style: TextStyle(
                  //fontFamily: "Roboto",
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10.0,
                )
              ],
            ),
            margin: EdgeInsets.only(
              left:   12.0,
              right:  12.0,
              top:    MediaQuery.sizeOf(context).height / 5,
              bottom: 20.0,
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              shadowColor: Colors.black,
              child: form,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget get form {
    printLog("printing bools: signup:$signup, App.Data.hasUsers${App.hasUsers}");
    if (signup) {
      return SignUpForm(title: widget.title, setLoginForm:loginForm);
    }
    return LoginForm(title:widget.title, setSignupForm:signupForm);
  }

  void loginForm() {
    printLog("Going to Login Form");
    setState(() => signup = false);
  }

  void signupForm() {
    printLog("Going to SignUp Form");
    setState(() => signup = true);
  }
}
