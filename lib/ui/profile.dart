import "package:avert/docs/document.dart";
import "package:avert/ui/module.dart";
import "package:avert/docs/profile.dart";
import "package:avert/ui/components/document.dart";
import "package:avert/ui/components/input.dart";
import "package:avert/ui/core.dart";
import "package:avert/utils/common.dart";
import "package:avert/utils/logger.dart";
import "package:avert/utils/ui.dart";

import "package:flutter/material.dart";
import "package:forui/forui.dart";

class ProfileForm extends StatefulWidget {
  const ProfileForm({super.key,
    required this.document,
    required this.onSubmit,
  });

  final Profile document;
  final Future<bool> Function() onSubmit;

  @override
  State<StatefulWidget> createState() => _NewState();
}

class _NewState extends State<ProfileForm> with TickerProviderStateMixin implements DocumentForm {
  late final FTabController _tabController;

  @override
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController> controllers = {
    "name": TextEditingController(),
  };

  @override
  bool isDirty = false;

  @override
  String? errMsg;

  @override
  void initState() {
    super.initState();
    _tabController = FTabController(length: Core.modules.length, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    for (TextEditingController c in controllers.values) {
      c.dispose();
    }
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    printTrack("Building ProfileDocumentForm");
    FThemeData theme = FTheme.of(context);
    return AvertDocumentForm(
      formKey: formKey,
      title: Text("${isNew(widget.document) ? "New" : "Edit"} Profile",),
      contents: [
        AvertInput.text(
          label: "Name",
          hint: "Ex. Acme Inc.",
          controller: controllers["name"]!,
          required: true,
          forceErrMsg: errMsg,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          initialValue: widget.document.name,
          onChange: (value) => onValueChange((){
            return value != widget.document.name;
          }),
        ),
        FDivider(),
      ],
      isDirty: isDirty,
      floatingActionButton: !isDirty ? null : FButton.icon(
        style: theme.buttonStyles.primary.copyWith(
          enabledBoxDecoration: theme.buttonStyles.primary.enabledBoxDecoration.copyWith(
            borderRadius: BorderRadius.circular(33),
          )
        ),
        onPress: submitDocument,
        child: Padding(
          padding: EdgeInsets.all(8),
          child: FIcon(FAssets.icons.save,
            size: 32,
          ),
        )
      ),
      resizeToAvoidBottomInset: true,
    );
  }

  @override
  void onValueChange(bool Function() isDirtyCallback) {
    final bool isReallyDirty = isDirtyCallback();
    if (isReallyDirty == isDirty) {
      return;
    }
    printTrack("Setting state of isdirty = $isReallyDirty");
    setState(() => isDirty = isReallyDirty );
  }

  @override
  void submitDocument() async {
    final bool isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    FocusScope.of(context).requestFocus(FocusNode());

    widget.document.name = controllers["name"]!.value.text;

    final bool success = await widget.onSubmit();

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }
}

class ProfileView extends StatefulWidget {
  const ProfileView({super.key,
    required this.document,
    required this.profile,
  });

  final Profile document, profile;

  @override
  State<StatefulWidget> createState() => _ViewState();
}

class _ViewState extends State<ProfileView> with TickerProviderStateMixin implements DocumentView<Profile> {
  late final FPopoverController _controller;

  @override
  late Profile document = widget.document;

  @override
  void initState() {
    super.initState();
    _controller = FPopoverController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final FThemeData theme = FTheme.of(context);
    final FCardContentStyle contentStyle = theme.cardStyle.contentStyle;
    printTrack("Building Profile Document View");
    final List<Widget> header = [
      Text(document.name, style: contentStyle.titleTextStyle),
      Text("", style: contentStyle.subtitleTextStyle),
    ];
    return AvertDocumentView<Profile>(
      controller: _controller,
      name: "Profile",
      header: header,
      editDocument: editDocument,
      deleteDocument: deleteDocument,
      content: Container(),
      prefix: FButton.raw(
        onPress: null,
        child: Container(
          alignment: Alignment.center,
          height: 150,
          width: 150,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: theme.avatarStyle.backgroundColor,
          ),
          clipBehavior: Clip.hardEdge,
          child: Text(getAcronym(document.name), style: theme.typography.xl6),
        ),
      ),
    );
  }

  @override
  Future<void> deleteDocument() async {
    final bool shouldDelete = await confirmDelete() ?? false;

    if (!shouldDelete) return;

    final bool success = await document.delete();
    if (success && mounted) {
      printWarn("Deleting Profile:${document.name} with id of: ${document.id}");
      Navigator.of(context).pop();
    }
  }

  @override
  void editDocument() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) => ProfileForm(
          document: document,
          onSubmit: _onEdit,
        ),
      )
    );
    if (document.action == DocAction.update) setState(() => document = widget.document);
  }

  Future<bool> _onEdit() async {
    String msg = "Error writing the document to the database!";
    final bool success = await document.update();
    if (success) msg = "Successfully changed profile details";
    if (mounted) notify(context, msg);
    return success;
  }

  Future<bool?> confirmDelete() {
    return showAdaptiveDialog<bool>(
      context: context,
      builder: (BuildContext context) => FDialog(
        direction: Axis.horizontal,
        title: Text("Delete '${widget.document.name}'?"),
        body: const Text("Are you sure you want to delete this Profile?"),
        actions: <Widget>[
          FButton(
            label: const Text("No"),
            style: FButtonStyle.outline,
            onPress: () => Navigator.of(context).pop(false),
          ),
          FButton(
            style: FButtonStyle.destructive,
            label: const Text("Yes"),
            onPress: () => Navigator.of(context).pop(true),
          ),
        ],
      ),
    );
  }
}
