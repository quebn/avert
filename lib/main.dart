import "package:flutter/material.dart";
import "package:avert/core/app.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await App.createAppDir();
  await App.initDB();
  runApp(const App());
}
