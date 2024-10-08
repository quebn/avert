import "package:flutter/material.dart";

class PromptScreen extends StatelessWidget {

  const PromptScreen({super.key, required this.promptName, required this.body, required this.footer});

  final String promptName;
  final Widget body;
  final Widget footer;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("New $promptName"),
      ),
      body: body,
      bottomNavigationBar: footer,
    );
  }
}
