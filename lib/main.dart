import "package:forui/theme.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:permission_handler/permission_handler.dart";
import "package:avert/core/auth/screen.dart";
import "package:avert/core/home/screen.dart";
import "package:avert/core/core.dart";
import "dart:io";

import "accounting/utils/database.dart";
import "core/utils/database.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await _createAppDir();
  User? user;
  Company? company;
  bool hasUsers = false;
  Core.database = await openDatabase("avert.db",
    version: 1,
    onCreate: _onCreate,
    onOpen: (db) async {
      final SharedPreferencesWithCache cachedPrefs = await SharedPreferencesWithCache.create(
        cacheOptions: const SharedPreferencesWithCacheOptions(
          allowList: <String>{"user_id", "company_id"},
        )
      );

      int userID = 0;
      if ( userID != 0 ) {
        user = await _fetchUser(db, userID);
      }
      hasUsers = user != null;
      if (!hasUsers) {
        List<Map<String, Object?>> results = await db.query("users",
          columns: ["id"],
        );
        printInfo("${results.length} user(s) found with values of: ${results.toString()}");
        hasUsers = results.isNotEmpty;
        //if (!hasUsers) await _createUser();
      }
      company = await Company.fetchDefault(db, cachedPrefs);
      //company = await _getCompany(db, cachedPrefs);
    },
  );
  printWarn("After opening of Database Path:${Core.database!.path}");
  runApp(App(
    title: "Avert",
    user: user,
    company: company,
    hasUsers: hasUsers,
  ));
}


class App extends StatelessWidget {
  const App({super.key,
    required this.title,
    required this.user,
    required this.company,
    this.hasUsers = true,
  });

  final String title;
  final User? user;
  final Company? company;
  final bool hasUsers;

  bool get hasUser => user != null;

  @override
  Widget build(BuildContext context) {
    _createAppDir();
    return FTheme(
      data: FThemes.zinc.dark,
      child: MaterialApp(
        themeMode: ThemeMode.system,
        title: title,
        //debugShowCheckedModeBanner: false,
        home:  hasUser
        ? HomeScreen(title: title, user: user!, company: company)
        : AuthScreen(title: title, hasUsers: hasUsers),
      ),
    );
  }
}

Future<User?> _fetchUser(Database db, int id) async {
 List<Map<String, Object?>> results = await db.query("users",
    columns: ["id", "name", "createdAt", "password"],
    where: "id = ?",
    whereArgs: [id],
  );

  printInfo("${results.length} user(s) found with values of: ${results.toString()}");
  if (results.isEmpty || id == 0) {
    return null;
  }

  for (Map<String, Object?> data in results) {
    if (id == data['id']) {
      printTrack("User found! setting user!");
      return User.fromQuery(
        id: data['id']!,
        name: data['name']!,
        createdAt: data['createdAt']!,
      );
    }
  }
  return null;
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
  printInfo("Creating Database tables");
  Batch batch = db.batch();

  tablesInitCore(batch);
  tablesInitAccounting(batch);

  await batch.commit();
}

Future<void> _createUser() async {
  User user = User(name: "Administrator");
  user.password = hashString("pass1234");
  bool success = await user.insert();
  if (success) printSuccess("Created User Successfully");
}
