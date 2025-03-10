import "package:avert/core/components/select.dart";
import "package:avert/core/core.dart";
import "package:avert/core/home/screen.dart";
import "package:avert/core/utils/ui.dart";
import "form_selector.dart";
import "form_creator.dart";
import "package:forui/forui.dart";

class GreeterScreen extends StatefulWidget {
  const GreeterScreen({super.key,
    required this.title,
    required this.profiles,
    this.initialProfile,
  });

  final String title;
  final List<Profile> profiles;
  final Profile? initialProfile;

  @override
  State<StatefulWidget> createState() => _ScreenState();
}

class _ScreenState extends State<GreeterScreen> with TickerProviderStateMixin{
  late final AvertSelectController<Profile> _selectController;
  late final FTabController _tabController;

  Profile get selectedProfile => _selectController.value!;

  @override
  void initState() {
    super.initState();
    _tabController = FTabController(length: 2, vsync: this, initialIndex: 0);
    _selectController = AvertSelectController<Profile>(
      value: widget.initialProfile ?? widget.profiles.firstOrNull
    );
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    // _selectController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    printTrack("Building Greeter Screen");
    final FThemeData theme = FTheme.of(context);
    final List<FTabEntry> tabs = [
      FTabEntry(
        label: const Text("Select",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: SelectProfileForm(
          profiles: widget.profiles,
          controller: _selectController,
          onEnter: widget.profiles.isNotEmpty ? () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => HomeScreen(
                  title: "Avert",
                  profile: selectedProfile,
                )
              ));
          }: null,
        ),
      ),
      FTabEntry(
        label: const Text("Create",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        content: CreateProfileForm(
          profiles: widget.profiles,
          onCreate: _onProfileCreate,
        ),
      ),
    ];

    Widget content = FScaffold(
      header: SizedBox(height: kToolbarHeight,),
      content: SingleChildScrollView(
        // margin: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            FHeader(
              title: Text(widget.title,
                style: theme.typography.xl3.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            FDivider(),
            FTabs(
              controller: _tabController,
              tabs: tabs,
            ),
          ],
        ),
      ),
    );
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      resizeToAvoidBottomInset: false,
      body: content,
    );
  }

  void _onProfileCreate(Profile profile) {
    _selectController.update(profile);//, selected: true);
    setState( () {
      widget.profiles.add(profile);
      _tabController.index = 0;
    });
    notify(context, "Profile '${profile.name}' has been successfully created!");
  }
}
