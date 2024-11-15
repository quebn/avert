import "package:avert/core/core.dart";
import "form_login.dart";
import "form_signup.dart";

// IMPORTANT: change login and signup form switching into a tab like functionality.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.title });

  final String title;

  @override
  State<StatefulWidget> createState() => _ScreenState();
}

class _ScreenState extends State<AuthScreen> {
  User? user;
  Database? database;
  bool isLogin = true;

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    checkUsers();
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
              child: isLogin
                ? LoginForm(widget.title, () => setState(() => isLogin = false))
                : SignUpForm(widget.title, () => setState(() => isLogin = true)),
            ),
          ),
        ],
      ),
    );
  }

  void checkUsers() async {
    List<Map<String, Object?>> results = await Core.database!.query("users",
      columns: ["id"],
    );
    if (isLogin && results.isEmpty) {
      setState(() => isLogin = false);
    }
  }
}
