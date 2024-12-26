import "package:flutter/material.dart";

class ListViewScreen extends StatefulWidget {
  const ListViewScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ListViewState();
}

class _ListViewState extends State<ListViewScreen> {
  List<String> list = [];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: list.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          height: 50,
          color: Colors.amber.shade500,
          child: Center(child: Text('Entry ${list[index]}')),
        );
      },
      separatorBuilder: (BuildContext context, int index) => const Divider(),
    );
  }
}
