import "package:avert/core/core.dart";

class HomeTitle extends StatefulWidget {
  const HomeTitle({super.key, required this.company, required this.onDelete});

  final Company company;
  final void Function()? onDelete;

  @override
  State<StatefulWidget> createState() => _TitleState();
}

class _TitleState extends State<HomeTitle> {

  String title = "N/A";

  @override
  void initState() {
      printTrack("initializing HomeTitle!");
      super.initState();
      title = widget.company.name;
  }

  @override
  Widget build(BuildContext context) {
    printSuccess("Building HomeTitle");
    return TextButton(
      onPressed: () {
        printDebug("Viewing Current Company!");
        Navigator.push(context,
          MaterialPageRoute(
            builder: (context) => CompanyView(
              company: widget.company,
              onDelete: widget.onDelete,
              onSave: update,
            ),
          )
        );
      },
      child: Text(title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 24,
        ),
      ),
    );
  }

  void update() {
    setState(() => title = widget.company.name);
  }
}
