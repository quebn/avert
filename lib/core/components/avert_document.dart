import "package:flutter/material.dart";
import "package:avert/core/utils/common.dart";

class AvertDocument extends StatelessWidget {
  const AvertDocument({super.key,
    required this.name,
    required this.titleChildren,
    this.onPop,
    this.image,
    this.body,
    this.headerContent,
    this.formKey,
    this.headerPadding,
    this.headerTitlePadding,
    this.headerContentPadding,
    this.bodyPadding,
    this.floationActionButton,
    this.actions,
    this.isDirty = true,
  });

  final String name;
  final EdgeInsetsGeometry? headerPadding, bodyPadding;
  final EdgeInsetsGeometry? headerContentPadding;
  final EdgeInsetsGeometry? headerTitlePadding;
  final Widget? floationActionButton;
  final Widget? image, headerContent, body;
  final GlobalKey<FormState>? formKey;
  final List<Widget>? actions;
  final List<Widget> titleChildren;
  final void Function()? onPop;
  final bool isDirty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        actions: actions,
      ),
      body: Form(
          canPop: !isDirty,
          onPopInvokedWithResult: (bool didPop, Object? value) async {
            if (didPop) {
              if (onPop != null && !isDirty) onPop!();
              return;
            }
            final bool shouldPop = await confirmPop(context) ?? false;
            if (shouldPop && context.mounted) {
              Navigator.pop(context);
            }
          },
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _headerContent(),
              _bodyContent(),
            ]
          ),
        ),
      floatingActionButton: floationActionButton,
    );
  }

  Widget _headerContent() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: headerPadding ?? EdgeInsets.all(8),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: image,
              ),
              Padding(
                padding: headerTitlePadding ?? EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: titleChildren,
                ),
              ),
            ]
          ),
          Container(
            margin: EdgeInsets.all(8),
            padding: headerContentPadding,
            child: headerContent,
          ),
        ],
      ),
    );
  }

  Widget _bodyContent() {
    return SingleChildScrollView(
      child: Container(
        padding: bodyPadding ?? EdgeInsets.all(8),
        color: Colors.white,
        child: body,
      ),
    );
  }
}

// IMPORTANT: should only be use for new Documents.
class AvertDocumentNew extends StatelessWidget {
  const AvertDocumentNew({super.key,
    required this.widgetsBody,
    required this.name,
    this.onPop,
    this.formKey,
    this.xPadding = 0,
    this.yPadding = 0,
    this.floationActionButton,
    this.widgetsFooter,
    this.leading,
    this.actions,
    this.isDirty = true,
    this.bgColor = Colors.white,
  });

  final String name;
  final double xPadding, yPadding;
  final List<Widget> widgetsBody;
  final GlobalKey<FormState>? formKey;
  final List<Widget>? widgetsFooter;
  final Widget? floationActionButton;
  final Widget? leading;
  final List<Widget>? actions;
  final void Function()? onPop;
  final bool isDirty;
  final Color? bgColor;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        actions: actions,
        leading: leading,
        title:Text("New $name",
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
          onPopInvokedWithResult: (bool didPop, Object? value) async {
            if (didPop) {
              if (onPop != null && !isDirty) onPop!();
              return;
            }
            final bool shouldPop = await confirmPop(context) ?? false;
            if (shouldPop && context.mounted) {
              Navigator.pop(context);
            }
          },
          key: formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: yPadding, horizontal: xPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
