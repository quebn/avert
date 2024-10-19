import "package:flutter/material.dart";
import "package:acqua/core.dart";
import "package:acqua/utils.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await App.createAppDir();
  await App.dbInit();
  printLog("After opening of Database Path:${App.db?.path}", level:LogLevel.warn);
  runApp(App());
}
