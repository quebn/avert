import "package:avert/core/core.dart";
import "package:avert/core/greeter/screen.dart";
import "package:avert/core/home/module_drawer.dart";
import "package:avert/core/utils/database.dart";
import "package:forui/forui.dart";

import "dashboard.dart";
import "documents.dart";
import "profile_drawer.dart";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key,
    required this.title,
    required this.profile,
  });

  final String title;
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
    Documents(module: currentModule, profile: currentProfile),
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
              Text(widget.title,
                style: FTheme.of(context).typography.xl2,
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
        profile: widget.profile,
        onDeleteProfile: () async {
          List<Profile> profiles = await fetchAllProfile();
          _logout(profiles);
        },
        onLogout: () async {
          bool shouldLogout = await _confirmLogout() ?? false;
          if (shouldLogout) {
            List<Profile> profiles = await fetchAllProfile();
            _logout(profiles);
          }
        },
      ),
      drawer: HomeModuleDrawer(
        currentModule: currentModule,
        onModuleSelect: (selected, module) { if (selected) printTrack("Selecting: ${module.name}");},
      ),
    );
  }

  void _logout(List<Profile> profiles) {
    printWarn("Logging Out");
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => GreeterScreen(
          title: widget.title,
          profiles: profiles,
        ),
      )
    );
  }

  Future<bool?> _confirmLogout() async {
    return showAdaptiveDialog<bool>(
      context: context,
      builder: (BuildContext context) => FDialog(
        direction: Axis.horizontal,
        title: Text("Log out?"),
        body: Text("Are you sure you want to logout user '${widget.profile.name}'?"),
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
