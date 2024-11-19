import "package:avert/core/core.dart";
import "form_login.dart";
import "form_signup.dart";

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.title , this.hasUsers});

  final String title;
  final bool? hasUsers;

  @override
  State<StatefulWidget> createState() => _ScreenState();
}

class _ScreenState extends State<AuthScreen> with TickerProviderStateMixin{
  User? user;
  Database? database;
  late bool hasUsers = widget.hasUsers ?? true;

  late final TabController _tabController;
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.index = hasUsers ? 0 : 1;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    printTrack("Building AuthScreen");
    if(widget.hasUsers == null) checkUsers();
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
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Scaffold(
                  appBar: formTab(),
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      const LoginForm(),
                      SignUpForm(
                        hasUsers: hasUsers,
                        //setLoginForm: () => setState(() =>  _tabController.index = 0)
                      ),
                    ],
                  ),
                ),
              ),
            )
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget formTab() {
    return TabBar(
      dividerColor: Colors.white,
      controller: _tabController,
      tabs: [
        Tab(
          child: Text( "Log In",
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Tab(
          child: Text( "Register",
            style: TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ]
    );
  }

  void checkUsers() async {
    List<Map<String, Object?>> results = await Core.database!.query("users",
      columns: ["id"],
    );
    hasUsers = results.isNotEmpty;
    if (_tabController.index == 0 && results.isEmpty) {
      setState(() => _tabController.index = 1);
    }
  }
}
