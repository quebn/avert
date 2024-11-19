import "package:avert/core/core.dart";

class HomeProfileDrawer extends StatefulWidget {
  const HomeProfileDrawer({super.key,
    required this.user,
    required this.onLogout,
    required this.onUserDelete,
  });

  final User user;
  final void Function() onLogout;
  final void Function() onUserDelete;

  @override
  State<StatefulWidget> createState() => _ProfileDrawerState();
}

class _ProfileDrawerState extends State<HomeProfileDrawer> {
  late String username = widget.user.name;
  // todo: have a variable that will update the users picture if changed.

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 250,
      child: Column(
        children: [
          DrawerHeader(
            margin: const EdgeInsets.only(left: 8, right: 8, bottom: 8, top: 32),
            decoration: const BoxDecoration(
              color: Colors.black,
            ),
            child: Center(
              child: Text(username,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const Text("Profile",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            onTap: () {
              printLog("Open Profile Page.");
              Navigator.push(context,
                MaterialPageRoute(
                  builder: (context) => UserView(
                    user: widget.user,
                    onDelete: widget.onUserDelete,
                    onSave: () {},
                  ),
                )
              );
            }
          ),
          Divider(),
          ListTile(
            leading: const Icon(Icons.check_box_rounded),
            title: const Text("Tasks",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            onTap: () { printLog("Open Task list");}
          ),
          Divider(),
          ListTile(
            leading: const Icon(Icons.groups_3_rounded),
            title: const Text("Users",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            onTap: () { printLog("Open User list");}
          ),
          Divider(),
          ListTile(
            leading: const Icon(Icons.business_rounded),
            title: const Text("Companies",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            onTap: () { printLog("Open Company list");}
          ),
          Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text("App Settings",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            onTap: () { printLog("Open Settings App Settings.");}
          ),
          Divider(),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Divider(),
                ListTile(
                  leading: const Icon(Icons.logout_rounded),
                  title: const Text("Log Out",
                    style: TextStyle(
                      fontSize: 16,
                      ),
                    ),
                  onTap: widget.onLogout,
                  ),
              ]
            ),
          ),
        ]
      )
    );
  }
}

