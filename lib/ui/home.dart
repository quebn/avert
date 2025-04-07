import "package:avert/docs/document.dart";
import "package:avert/ui/module.dart";
import "package:avert/docs/profile.dart";
import "package:avert/ui/greeter.dart";
import "package:avert/ui/profile.dart";
import "package:avert/utils/database.dart";
import "package:avert/utils/logger.dart";
import "package:flutter/material.dart";
import "package:forui/forui.dart";

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

class Documents extends StatelessWidget {
  const Documents({super.key,
    required this.profile,
    required this.module,
  });

  final Profile profile;
  final Module module;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: module.documents(context, profile),
    );
  }
}

class Dashboard extends StatelessWidget {
  const Dashboard({super.key,
    required this.module,
  });

  final Module module;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            child: module.dashboardBody(context),
          ),
        ]
      ),
    );
  }
}

class HomeModuleDrawer extends StatelessWidget {
  const HomeModuleDrawer({super.key,
    required this.currentModule,
    required this.onModuleSelect,
  });

  final Module currentModule;
  final void Function(bool selected, Module module) onModuleSelect;

  @override
  Widget build(BuildContext context) {
    final FThemeData theme = FTheme.of(context);
    printTrack("Building Home Module Drawer!");
    return Drawer(
      backgroundColor: theme.colorScheme.background,
      width: 200,
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.viewPaddingOf(context).top,
          left: 8,
          right: 8,
        ),
        child: Column(
          children: [
            SizedBox(height: 24),
            FSelectTileGroup<Module>(
              style: theme.tileGroupStyle.copyWith(
                tileStyle: theme.tileGroupStyle.tileStyle.copyWith(
                  focusedBorder: Border.all(style: BorderStyle.none),
                  border: Border.all(style: BorderStyle.none),
                  enabledBackgroundColor: theme.colorScheme.secondary
                ),
              ),
              groupController: FRadioSelectGroupController(value: currentModule),
              divider: FTileDivider.full,
              label: const Text("Modules"),
              children: drawerModuleTiles,
            )
          ]
        )
      )
    );
  }

  List<FSelectTile<Module>> get drawerModuleTiles {
    final List<Module> modules = Core.modules;
    final List<FSelectTile<Module>> items = [];
    if (modules.isEmpty) return items;
    for (final Module m in modules) {
      items.add(
        FSelectTile<Module>.suffix(
          value: m,
          prefixIcon: m.icon,
          title: Text(m.name),
          onFocusChange: (selected) => onModuleSelect(selected, m),
          checkedIcon: SizedBox(),
        ),
      );
    }
    return items;
  }
}

class HomeProfileDrawer extends StatefulWidget {
  const HomeProfileDrawer({super.key,
    required this.profile,
    required this.onLogout,
    required this.onDeleteProfile,
  });

  final Profile profile;
  final void Function() onLogout;
  final void Function() onDeleteProfile;

  @override
  State<StatefulWidget> createState() => _ProfileDrawerState();
}

class _ProfileDrawerState extends State<HomeProfileDrawer> {
  late String _profileName = widget.profile.name;

  @override
  Widget build(BuildContext context) {
    printTrack("Building Home Profile Drawer!");
    final FThemeData theme = FTheme.of(context);
    return Drawer(
      backgroundColor: theme.colorScheme.background,
      width: 200,
      child: Padding(
        padding: EdgeInsets.only(
          top: MediaQuery.viewPaddingOf(context).top,
          left: 8,
          right: 8,
        ),
        child: Column(
          children: [
            SizedBox(height: 24),
            _profile(context),
            FTileGroup(
              style: theme.tileGroupStyle.copyWith(
                tileStyle: theme.tileGroupStyle.tileStyle.copyWith(
                  focusedBorder: Border.all(style: BorderStyle.none),
                  border: Border.symmetric(
                    vertical: BorderSide.none,
                    horizontal: BorderSide(
                      color: theme.colorScheme.border
                    ),
                  ),
                  borderRadius: BorderRadius.all(Radius.zero),
                ),
              ),
              divider: FTileDivider.full,
              children: [
                FTile(
                  onPress: _viewProfile,
                  prefixIcon: FIcon(FAssets.icons.circleUserRound),
                  title: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child:Text("Profile")
                  ),
                ),
              ],
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FDivider(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: FButton(
                      style: FButtonStyle.destructive,
                      prefix: FIcon(FAssets.icons.logOut),
                      label: const Text("Log Out"),
                      onPress: widget.onLogout,
                    ),
                  ),
                  FDivider(),
                ]
              ),
            ),
          ]
        )
      )
    );
  }

  void _viewProfile() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => ProfileView(
          document: widget.profile,
          profile: widget.profile,
          //deleteDocument: widget.onDeleteProfile,
        ),
      ),
    );
    if (widget.profile.action == DocAction.none) return;
    switch (widget.profile.action) {
      case DocAction.update:
        setState(() => _profileName = widget.profile.name);
        break;
      case DocAction.delete:
        widget.onDeleteProfile();
        break;
      default :
        break;
    }
  }

  Widget _profile(BuildContext context) => SizedBox(
    child: Column(
      children: [
        Container(
          alignment: Alignment.center,
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: FTheme.of(context).avatarStyle.backgroundColor,
            //image: image != null ? DecorationImage(
            //  image: image!,
            //  fit: BoxFit.cover,
            //) : null,
          ),
          clipBehavior: Clip.hardEdge,
          child: FIcon(FAssets.icons.user,
            size: 80,
          ),
        ),
        Text(
          _profileName,
          style: FTheme.of(context).typography.lg.copyWith(
            color: FTheme.of(context).colorScheme.foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
        FBadge(
          label: const Text("Default")
        ),
        SizedBox(height: 24),
      ],
    ),
  );
}

