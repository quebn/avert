import "package:avert/core/core.dart";
import "package:avert/core/documents/profile/view.dart";
import "package:forui/forui.dart";

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
    Profile? profile = await Navigator.of(context).push<Profile>(
      MaterialPageRoute(
        builder: (BuildContext context) => ProfileView(
          document: widget.profile,
          profile: widget.profile,
          deleteDocument: widget.onDeleteProfile,
        ),
      ),
    );

    if (profile != null) {
      setState(() => _profileName = profile.name);
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

