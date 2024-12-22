import "package:avert/core/core.dart";
import "package:avert/core/documents/profile/view.dart";
import "package:avert/core/greeter/screen.dart";
import "package:avert/core/home/module_drawer.dart";
import "package:avert/core/utils/ui.dart";
import "package:forui/forui.dart";

import "dashboard.dart";
import "profile_drawer.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key,
    required this.title,
    required this.user,
    required this.profile,
  });

  final String title;
  final User user;
  final Profile profile;

  @override
  State<StatefulWidget> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // TODO: should get the last session module but for now default to first index of module list.
  Module currentModule = Core.modules[0];
  int currentIndex = 0;
  bool lastStatus = true;

  final double height = 390;
  Profile get currentProfile => widget.profile;

  late List<Widget> pages = [
    Dashboard(module: currentModule),
    const Center(child: Text("Documents")),
    const Center(child: Text("Reports")),
    const Center(child: Text("Settings")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FScaffold(
        header: FHeader(
          title: Row(
            children: [
              Builder(
                builder: (BuildContext context) => FButton.icon(
                  onPress: () => Scaffold.of(context).openDrawer(),
                  style: FButtonStyle.ghost,
                  child: FIcon(FAssets.icons.menu,
                    size: 24,
                  ),
                ),
              ),
              SizedBox(width: 16,),
              FButton.raw(
                style: FButtonStyle.ghost,
                onPress: viewCurrentCompany,
                child: Text(currentProfile.name,
                  style: FTheme.of(context).typography.xl2,
                ),
              ),
            ],
          ),
          actions: [
            FHeaderAction(
              icon: FIcon(FAssets.icons.bell,
                size: 24,
              ),
              onPress: null,
            ),
            Builder(
              builder: (BuildContext context) => FButton.icon(
                style: FButtonStyle.ghost,
                onPress: () => Scaffold.of(context).openEndDrawer(),
                child: FAvatar.raw(
                  child: FIcon(FAssets.icons.user),
                ),
              ),
            )
          ],
        ),
        content: pages[currentIndex],
        footer: FBottomNavigationBar(
          index: currentIndex,
          onChange: (index) => setState(() => currentIndex = index),
          children: [
            FBottomNavigationBarItem(
              icon: FIcon(FAssets.icons.layoutDashboard),
              label: const Text("Dashboard"),
            ),
            FBottomNavigationBarItem(
              icon: FIcon(FAssets.icons.bookText),
              label: const Text("Documents"),
            ),
            FBottomNavigationBarItem(
              icon: FIcon(FAssets.icons.chartNoAxesCombined),
              label: const Text("Reports"),
            ),
            FBottomNavigationBarItem(
              icon: FIcon(FAssets.icons.settings),
              label: const Text("Settings"),
            ),
          ],
        ),
      ),
      endDrawer: HomeProfileDrawer(
        user: widget.user,
        onLogout: () => logout(context),
        onUserDelete: () {
          widget.user.forget();
          Navigator.pop(context);
          Navigator.push(context,
            MaterialPageRoute(
              builder: (context) => GreeterScreen(
                title: "Avert",
                profiles: [],
              ),
            )
          );
        },
      ),
      drawer: HomeModuleDrawer(
        currentModule: currentModule,
        onModuleSelect: (selected, module) { if (selected) printTrack("Selecting: ${module.name}");},
      ),
    );
  }

  void onCompanyDelete() {
    final String m = "Profile '${currentProfile.name}' successfully deleted!";
    printInfo("notifying of company deletion");
    // TODO: should redirect to Greeter on Profile Deletion
    notify(context, m);
  }

  Widget leftDrawer() {
    return const Drawer(
      width: 250,
      //child: Listjk
    );
  }

  void viewCurrentCompany() {
    printInfo("Viewing Current Company!");
    Navigator.push(context,
      MaterialPageRoute(
        builder: (context) => ProfileView(
          document: currentProfile,
          onDelete: onCompanyDelete,
          onUpdate: () {
            throw UnimplementedError();
            //printError("From Main Display of HomeScreen");
            //setState(() {});
          }
        ),
      )
    );
  }

  Future<void> logout(BuildContext context) async {
    bool shouldLogout = await confirmLogout() ?? false;

    if (shouldLogout && context.mounted) {
      widget.user.forget();
      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => GreeterScreen(
            title: "Avert",
            profiles: [],
          ),
        )
      );
    }
  }

  Future<bool?> confirmLogout() async {
    return showAdaptiveDialog<bool>(
      context: context,
      builder: (BuildContext context) => FDialog(
        direction: Axis.horizontal,
        title: Text("Log out?"),
        body: Text("Are you sure you want to logout user '${widget.user.name}'?"),
        actions: <Widget>[
          FButton(
            label: const Text("No"),
            style: FButtonStyle.outline,
            onPress: () {
              Navigator.of(context).pop(false);
            },
          ),
          FButton(
            style: FButtonStyle.destructive,
            label: const Text("Yes"),
            onPress: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    );
  }
}
