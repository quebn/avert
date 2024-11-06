import "package:flutter/material.dart";

class AcquaDocument extends StatelessWidget {
  const AcquaDocument({super.key, 
    required this.title, 
    required this.widgetsBody,
    this.formKey, 
    this.actionButton,
    this.widgetsFooter,
    this.leading,
  });

  final String title;
  final List<Widget> widgetsBody;
  final GlobalKey<FormState>? formKey;
  final List<Widget>? widgetsFooter;
  final Widget? actionButton;
  final Widget? leading;
  //final List<Widget> widgets;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: leading,
        centerTitle: true,
        title: Text(title,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontSize: 28,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            children: widgetsBody
          ),
        ),
      ),
      floatingActionButton: actionButton,
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: widgetsFooter,
    );
  }
}
