import "package:flutter/material.dart";
import "package:forui/forui.dart";
import "package:avert/core/utils/ui.dart";

class AvertDocumentView extends StatelessWidget {
  const AvertDocumentView({super.key,
    required this.name,
    required this.title,
    this.image,
    this.body,
    this.header,
    this.actions,
  });

  final String name;
  final Widget? image, header, body;
  final List<Widget>? actions;
  final Widget title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: FScaffold(
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _headerContent(),
            _bodyContent(),
          ]
        ),
      ),
    );
  }

  Widget _headerContent() {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                child: image,
              ),
              Container(
                child: title,
              ),
            ]
          ),
          Container(
            margin: EdgeInsets.all(8),
            child: header,
          ),
        ],
      ),
    );
  }

  Widget _bodyContent() {
    return Container(
      child: body,
    );
  }
}

class AvertDocumentForm extends StatelessWidget {
  const AvertDocumentForm({super.key,
    required this.title,
    required this.contents,
    this.floatingActionButton,
    this.leading,
    this.formKey,
    this.actions,
    this.isDirty = true,
  });

  final Widget title;
  final Widget? floatingActionButton;
  final List<Widget> contents;
  final GlobalKey<FormState>? formKey;
  final Widget? leading;
  final List<Widget>? actions;
  final bool isDirty;

  @override
  Widget build(BuildContext context) {
    //final FThemeData theme = FTheme.of(context);
    return Scaffold(
      body: FScaffold(
        header: FHeader(
          title: title,
        ),
        content: Form(
          key: formKey,
          canPop: !isDirty,
          onPopInvokedWithResult: (bool didPop, Object? value) async {
            if (didPop) {
              return;
            }
            final bool shouldPop = await confirm(context) ?? false;
            if (shouldPop && context.mounted) {
              Navigator.pop(context);
            }
          },
          child: Column(
            children: contents,
          ),
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
