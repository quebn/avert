import "package:flutter/material.dart";
import "package:avert/core.dart";

class HomeTitle extends StatefulWidget {
  const HomeTitle({super.key, required this.onDelete});

  final void Function()? onDelete;
  @override
  State<StatefulWidget> createState() => _TitleState();
}

class _TitleState extends State<HomeTitle> {

  String title = App.company!.name;

  @override
  Widget build(BuildContext context) {
    printSuccess("Building HomeTitle");
    return TextButton(
      onPressed: () {
        printDebug("Viewing Current Company!");
        Navigator.push(context,
          MaterialPageRoute(
            builder: (context) => CompanyView(
              company: App.company!,
              onDelete: widget.onDelete,
              onSave: () => setState(() => title = App.company!.name)
            ),
          )
        );
      },
      child: Text(App.company!.name,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 24,
        ),
      ),
    );
  }
}
