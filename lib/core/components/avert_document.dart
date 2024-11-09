import "package:flutter/material.dart";

class AvertDocument extends StatelessWidget {
  const AvertDocument({super.key, 
    required this.title, 
    required this.widgetsBody,
    this.formKey,
    this.xPadding = 0,
    this.yPadding = 0,
    this.floationActionButton,
    this.widgetsFooter,
    this.leading,
    this.onPop,
    this.actions,
    this.isDirty = true,
  });

  final String title;
  final double xPadding, yPadding;
  final List<Widget> widgetsBody;
  final GlobalKey<FormState>? formKey;
  final List<Widget>? widgetsFooter;
  final Widget? floationActionButton;
  final Widget? leading;
  final List<Widget>? actions;
  final void Function(bool, Object?)? onPop;
  final bool isDirty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: actions,
        leading: leading,
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
          canPop: !isDirty,
          onPopInvokedWithResult: onPop,
          key: formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: yPadding, horizontal: xPadding),
            child: Column(
              children: widgetsBody
            ),
          ),
        ),
      ),
      floatingActionButton: floationActionButton,
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: widgetsFooter,
    );
  }
}
