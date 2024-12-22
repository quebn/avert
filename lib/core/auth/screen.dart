import "package:avert/core/core.dart";
import "form_login.dart";
import "form_signup.dart";
import "package:forui/forui.dart";

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
    _tabController = FTabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = FScaffold(
      header: SizedBox(height: kToolbarHeight,),
      content:  Container(
        margin: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            FHeader(
              title: Text(widget.title,
                style: const TextStyle(
                  fontSize: 32,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            FDivider(),
            FTabs(
              controller: _tabController,
              tabs: [
                FTabEntry(
                  label: const Text("Login",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  content: const LoginForm(),
                ),
                FTabEntry(
                  label: const Text("Register",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  content: SignUpForm(
                    hasUsers: widget.hasUsers ?? true,
                    gotoLoginForm: () => setState( () => _tabController.index = 0 ),
                  ),
                ),
              ],
            ),
          ],
        ),
      )
    );
    final FThemeData theme = FTheme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      resizeToAvoidBottomInset: false,
      body: content,
    );
  }
}
