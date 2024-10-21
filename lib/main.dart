import "package:flutter/material.dart";
import "package:acqua/core/app.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await App.createAppDir();
  await App.dbInit();
  runApp(App());
}
