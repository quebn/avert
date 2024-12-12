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
  late final FTabController _tabController;

  @override
  void initState() {
    super.initState();
    printInfo("Has Users: $hasUsers");
    _tabController = FTabController(length: 2, vsync: this, initialIndex: hasUsers ? 0 : 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    printTrack("Building AuthScreen");
    return FTheme(
      data: FThemes.zinc.dark,
      child: FScaffold(
        header: SizedBox(height: kToolbarHeight,),
        content: Container(
          margin: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              FHeader(
                title: const Text("Avert",
                  style: TextStyle(
                    fontSize: 32,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              FDivider(),
              FTabs(
                initialIndex: hasUsers ? 0 : 1,
                controller: _tabController,
                tabs: [
                  FTabEntry(
                    label: const Text("Login",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    content: LoginForm(),
                  ),
                  FTabEntry(
                    label: const Text("Register",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    content: SignUpForm(
                      hasUsers: hasUsers,
                      onRegister: () => setState( () => _tabController.index = 0),
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
      ),
    );
  }
}
