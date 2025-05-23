import "package:avert/docs/document.dart";
import "package:avert/ui/components/select.dart";
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
  }): isDialog = false;

  const ProfileForm.dialog({super.key,
    required this.document,
    required this.onSubmit,
  }): isDialog = true;

  final Profile document;
  final Future<String?> Function() onSubmit;
  final bool isDialog;

  @override
  State<StatefulWidget> createState() => _NewState();
}

class _NewState extends State<ProfileForm> with TickerProviderStateMixin implements DocumentForm {
  late final FTabController tabController;
  late final AvertSelectController<Currency> currencyController;

  @override
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final Map<String, TextEditingController> controllers = {
    "name": TextEditingController(),
  };

  Profile get document => widget.document;

  @override
  bool isDirty = false;

  @override
  String? errMsg;

  @override
  void initState() {
    super.initState();
    tabController = FTabController(length: Core.modules.length, vsync: this);
    currencyController = AvertSelectController(
      value: isNew(document) ? Currency.nil : document.currency
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (TextEditingController c in controllers.values) {
      c.dispose();
    }
    tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    printTrack("Building ProfileDocumentForm");
    FThemeData theme = FTheme.of(context);
    final List<Widget> contents = [
      AvertInput.text(
        label: "Name",
        hint: "Ex. Acme Inc.",
        controller: controllers["name"]!,
        required: true,
        forceErrMsg: errMsg,
        // autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: validateName,
        initialValue: widget.document.name,
        onChange: (value) => onValueChange(setState, this, (){
          return value != widget.document.name;
        }),
      ),
      AvertSelect<Currency>(
        options: Currency.values.toList(),
        label: "Currency",
        prefix: FIcon(FAssets.icons.currency),
        required: true,
        valueBuilder: (context, currency) => Text(currency?.toString() ?? "None"),
        controller: currencyController,
        tileSelectBuilder: (context, value) => AvertSelectTile<Currency>(
          selected: currencyController.value == value,
          value: value,
          prefix: FIcon(FAssets.icons.currency),
          title: Text(value.toString(), style: theme.typography.base),
        ),
      ),
    ];
    return widget.isDialog
    ? AvertDocumentForm<Profile>.dialog(
      formKey: formKey,
      title: const Text("Create New Profile"),
      isDirty: isDirty,
      contents: contents,
      actions: [
        FButton(
          style: theme.buttonStyles.destructive,
          label: const Text(
            "Cancel",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          onPress: () => Navigator.of(context).pop<bool>(false),
        ),
        FButton(
          label: const Text(
            "Create",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          onPress: submitDocument,
        ),
      ],
    )
    : AvertDocumentForm<Profile>(
      formKey: formKey,
      title: const Text("Edit Profile"),
      contents: contents,
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
  void submitDocument() async {
    final bool isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    FocusScope.of(context).requestFocus(FocusNode());

    document.name = controllers["name"]!.value.text;
    document.currency = currencyController.value!;

    final String? error = await widget.onSubmit();

    if (!mounted) return;
    if (error == null) {
      Navigator.of(context).pop<bool>(true);
    } else {
      notify(context, error);
    }
  }

  String? validateName(String? value) {
    if (value == null || value == "") return "Name should not be empty";
    return null;
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

    final String? error = await document.delete();
    if (error == null && mounted) {
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

  Future<String?> _onEdit() async {
    final String? error = await document.update();
    String msg = error ?? "Successfully changed profile details";
    if (mounted) notify(context, msg);
    return error;
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
