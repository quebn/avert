import "package:flutter/material.dart";
import "package:avert/core/utils/common.dart";

class AvertDocumentView extends StatelessWidget {
  const AvertDocumentView({super.key,
    required this.name,
    required this.titleChildren,
    this.image,
    this.body,
    this.headerContent,
    this.headerPadding,
    this.headerTitlePadding,
    this.headerContentPadding,
    this.bodyPadding,
    this.actions,
    this.floatingActionButton,
  });

  final String name;
  final EdgeInsetsGeometry? headerPadding, bodyPadding;
  final EdgeInsetsGeometry? headerContentPadding;
  final EdgeInsetsGeometry? headerTitlePadding;
  final Widget? floatingActionButton;
  final Widget? image, headerContent, body;
  final List<Widget>? actions;
  final List<Widget> titleChildren;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        actions: actions,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _headerContent(),
          _bodyContent(),
        ]
      ),
      floatingActionButton: floatingActionButton,
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
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            color: Colors.white,
            padding: bodyPadding ?? EdgeInsets.all(8),
            child: body,
          ),
        ),
      ],
    );
  }
}

class AvertDocumentForm extends StatelessWidget {
  const AvertDocumentForm({super.key,
    required this.widgetsBody,
    required this.title,
    this.formKey,
    this.xPadding = 0,
    this.yPadding = 0,
    this.floatingActionButton,
    this.widgetsFooter,
    this.leading,
    this.actions,
    this.isDirty = true,
    this.bgColor = Colors.white,
    //this.onPop,
  });

  final String title;
  final double xPadding, yPadding;
  final List<Widget> widgetsBody;
  final GlobalKey<FormState>? formKey;
  final List<Widget>? widgetsFooter;
  final Widget? floatingActionButton;
  final Widget? leading;
  final List<Widget>? actions;
  final bool isDirty;
  final Color? bgColor;
  //final void Function()? onPop;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        actions: actions,
        leading: leading,
        title:Text(title,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontSize: 24,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          canPop: !isDirty,
          onPopInvokedWithResult: (bool didPop, Object? value) async {
            if (didPop) {
              //if (onPop != null && !isDirty) onPop!();
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
      floatingActionButton: floatingActionButton,
      persistentFooterAlignment: AlignmentDirectional.center,
      persistentFooterButtons: widgetsFooter,
    );
  }
}
