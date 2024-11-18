import "package:shared_preferences/shared_preferences.dart";
import "package:permission_handler/permission_handler.dart";
import "package:avert/core/auth/screen.dart";
import "package:avert/core/home/screen.dart";
import "package:avert/core/core.dart";
import "dart:io";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _createAppDir();
  User? user;
  Company? company;
  Core.database = await openDatabase("avert.db",
    version: 1,
    onCreate: _onCreate,
    onOpen: (db) async {
      final SharedPreferencesWithCache cachedPrefs = await SharedPreferencesWithCache.create(
        cacheOptions: const SharedPreferencesWithCacheOptions(
          allowList: <String>{"user_id", "company_id"},
        )
      );
      user = await _getUser(db, cachedPrefs);
      company = await Company.fetchDefault(db, cachedPrefs);
      //company = await _getCompany(db, cachedPrefs);
    },
  );
  printWarn("After opening of Database Path:${Core.database!.path}");
  runApp(App(
    title: "Avert",
    user: user,
    company: company,
  ));
}


class App extends StatelessWidget {
  const App({super.key,
    required this.title,
    required this.user,
    required this.company,
  });

  final String title;
  final User? user;
  final Company? company;

  bool get hasUser => user != null;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      //debugShowCheckedModeBanner: false,
      theme: ThemeData(
        dividerTheme: DividerThemeData(
          space: 8,
          indent: 8,
          endIndent: 8,
          color: Colors.grey,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        colorScheme: ColorScheme(
          brightness: Brightness.light,
          surface: Colors.white,
          onSurface: Colors.black,
          primary: Colors.black,
          onPrimary: Colors.white,
          secondary: Colors.white,
          onSecondary: Colors.black,
          error: Colors.red,
          onError: Colors.white,
        ),
        useMaterial3: true,
      ),
      home: hasUser
        ? HomeScreen(title: title, user: user!, company: company)
        : AuthScreen(title: title),
    );
  }
}

Future<User?> _getUser(Database db, SharedPreferencesWithCache sharedPrefs) async {
  List<Map<String, Object?>> results = await db.query("users",
    columns: ["id", "name", "createdAt", "password"]
  );

  int userID = sharedPrefs.getInt("user_id") ?? 0;
  if (results.isEmpty || userID == 0) {
    return null;
  }

  printLog("${results.length} user(s) found with values of: ${results.toString()}");
  for (Map<String, Object?> data in results) {
    if (userID == data['id']) {
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
    printDebug("Storage access permission denied!", level: LogLevel.error);
  } else {
    printDebug("Storage access permission granted!");
  }
  Directory dir = await Directory(path).create(recursive: true);
  printDebug("Avert Directory path: ${dir.path} uri: ${dir.uri}", level:LogLevel.warn);
  return status.isDenied;
}

_onCreate(Database db, int version) async {
  printDebug("Creating Database tables");
  Batch batch = db.batch();
  batch.execute(User.getTableQuery());
  batch.execute(Company.getTableQuery());
  batch.execute(Task.getTableQuery());
  //batch.execute(Accounting.getTableQuery()):
  await batch.commit();
}
