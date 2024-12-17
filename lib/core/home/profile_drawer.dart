import "package:avert/core/core.dart";
import "package:avert/core/documents/user/view.dart";
import "package:forui/forui.dart";

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

  @override
  Widget build(BuildContext context) {
    printTrack("Building Home Profile Drawer!");
    final FThemeData theme = context.theme;
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
            profile(context),
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
                  onPress: viewProfile,
                  prefixIcon: FIcon(FAssets.icons.circleUserRound),
                  title: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child:Text("Profile")
                  ),
                ),
                FTile(
                  onPress: null,
                  prefixIcon: FIcon(FAssets.icons.building2),
                  title: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child:Text("Companies")
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

  void viewProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => UserView(
          document: widget.user,
          user: widget.user,
          onUpdate: null,
          onDelete: null,
        ),
      ),
    );
  }

  Widget profile(BuildContext context) => SizedBox(
    child: Column(
      children: [
        Container(
          alignment: Alignment.center,
          height: 100,
          width: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: context.theme.avatarStyle.backgroundColor,
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
        //FAvatar.raw(
        //  child: Text(getAcronym(username)),
        //),
        Text(
          username,
          style: context.theme.typography.lg.copyWith(
            color: context.theme.colorScheme.foreground,
            fontWeight: FontWeight.w600,
          ),
        ),
        widget.user.isAdmin
        ? FBadge(
          style: FBadgeStyle.destructive,
          label: const Text("Admin")
        )
        : FBadge(
          label: const Text("User")
        ),
        SizedBox(height: 24),
      ],
    ),
  );
}

