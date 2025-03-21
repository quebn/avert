import "package:avert/core/core.dart";
import "package:avert/core/greeter/screen.dart";
import "package:permission_handler/permission_handler.dart";
import "package:forui/theme.dart";
import "dart:io";

import "accounting/utils/database.dart";
import "core/utils/database.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  List<Profile> profiles = [];
  Core.database = await openDatabase("avert.db",
    version: 1,
    onCreate: _onCreate,
    onOpen: (db) async {
      profiles = await fetchAllProfile(database: db);
    }
  );
  printWarn("After opening of Database Path:${Core.database!.path}");
  runApp(App(
    title: "Avert",
    profiles: profiles,
  ));
}


class App extends StatelessWidget {
  const App({super.key,
    required this.title,
    required this.profiles,
  });

  final String title;
  final List<Profile> profiles;

  @override
  Widget build(BuildContext context) {
    _createAppDir();
    return FTheme(
      data: FThemes.zinc.dark,
      child: MaterialApp(
        themeMode: ThemeMode.system,
        title: title,
        home:  GreeterScreen(
          title: title,
          profiles: profiles,
          initialProfile: profiles.isNotEmpty ? profiles[0] : null,
        ),
      ),
    );
  }
}

Future<bool> _createAppDir() async {
  if (!Platform.isAndroid) {
    return false;
  }
  const String path = "/storage/emulated/0/Avert";
  var status = await Permission.manageExternalStorage.request();
  if (status.isDenied) {
    printError("Storage access permission denied!");
  } else {
    printInfo("Storage access permission granted!");
  }
  Directory dir = await Directory(path).create(recursive: true);
  printWarn("Avert Directory path: ${dir.path} uri: ${dir.uri}");
  return status.isDenied;
}

_onCreate(Database db, int version) async {
  Batch batch = db.batch();

  createCoreTables(batch);
  createAccountingTables(batch);

  await batch.commit();
}
