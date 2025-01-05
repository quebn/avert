import "package:avert/core/components/avert_document.dart";
import "package:avert/core/components/avert_input.dart";
import "package:avert/core/components/avert_select.dart";
import "package:avert/core/components/avert_toggle.dart";
import "package:avert/core/core.dart";
import "package:forui/forui.dart";

import "document.dart";

class AccountForm extends StatefulWidget {
  const AccountForm({super.key,
    required this.document,
    required this.profile,
    required this.onSubmit,
  });

  final Account document;
  final Profile profile;
  final Future<Result<Account>> Function() onSubmit;

  @override
  State<StatefulWidget> createState() => _NewState();
}

class _NewState extends State<AccountForm> with SingleTickerProviderStateMixin implements DocumentForm {

  @override
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late final FRadioSelectGroupController<AccountRoot> _rootSelectController;
  late final FRadioSelectGroupController<AccountType> _typeSelectController;
  late final FRadioSelectGroupController<Account> _parentSelectController;

  @override
  final Map<String, TextEditingController> controllers = {
    'name': TextEditingController(),
  };

  @override
  bool isDirty = false;

  @override
  String? errMsg;

  @override
  void initState() {
    super.initState();
    _rootSelectController = FRadioSelectGroupController<AccountRoot>(value: AccountRoot.asset);
    _typeSelectController = FRadioSelectGroupController<AccountType>(value: AccountType.none);
    _parentSelectController = FRadioSelectGroupController<Account>();
  }

  @override
  void dispose() {
    super.dispose();
    for (TextEditingController controller in controllers.values) {
      controller.dispose();
    }
    _rootSelectController.dispose();
    _typeSelectController.dispose();
    _parentSelectController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    printTrack("Building AccountDocumentForm");
    return AvertDocumentForm<Account>(
      formKey: formKey,
      title: Text("${isNew(widget.document) ? "New" : "Edit"} Account",),
      contents: [
        AvertInput.text(
          label: "Name",
          hint: "Ex. Cash Account",
          controller: controllers['name']!,
          required: true,
          forceErrMsg: errMsg,
          initialValue: widget.document.name,
          onChange: (value) => onValueChange((){
            return value != widget.document.name;
          }),
        ),
        SizedBox(height: 8),
        Row(
          spacing: 8,
          children: [
            AvertSelect<AccountRoot>(
              controller: _rootSelectController,
              options: AccountRoot.values.toList(),
              flex: 1,
              label: "Root Type",
              prefix: FIcon(FAssets.icons.folderRoot),
              valueBuilder: (context, root) => Text(root.toString()),
              tileSelectBuilder: (context, value) {
                return FSelectTile<AccountRoot>.suffix(
                  title: Text(value.toString()),
                  value: value
                );
              },
            ),
            AvertSelect<AccountType>(
              controller: _typeSelectController,
              options: AccountType.values.toList(),
              flex: 1,
              label: "Account Type",
              prefix: FIcon(FAssets.icons.fileType),
              valueBuilder: (context, type) => Text(type?.displayName ?? "No Type Found"),
              tileSelectBuilder: (context, value) {
                return FSelectTile<AccountType>.suffix(
                  title: Text(value.displayName),
                  value: value
                );
              },
            )
          ]
        ),
        SizedBox(height: 8),
        Row(
          spacing: 8,
          children: [
            AvertSelect<Account>.queryOptions(
              flex: 1,
              controller: _parentSelectController,
              optionsQuery: null, // TODO: create query for this
              label: "Parent",
              prefix: FIcon(FAssets.icons.fileType),
              valueBuilder: (context, type) => Text(type?.name ?? "No Account Available"),
              tileSelectBuilder: (context, value) {
                return FSelectTile<Account>.suffix(
                  title: Text(value.name),
                  subtitle: Text(value.root.toString()) ,
                  value: value
                );
              },
            ),
            AvertToggle(
              label: "is Group",
              initialValue: widget.document.isGroup,
              onChange: (value) {
                widget.document.isGroup = value;
              },
            ),
          ]
        ),
        // TODO: add table
      ],
      isDirty: isDirty,
      floatingActionButton: !isDirty ? null : IconButton.filled(
        onPressed: submitDocument,
        iconSize: 48,
        icon: Icon(Icons.save_rounded)
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
    printTrack("Setting state of is dirty = $isReallyDirty");
    setState(() {
      isDirty = isReallyDirty;
    });
  }

  @override
  void submitDocument() async {
    final bool isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    FocusScope.of(context).requestFocus(FocusNode());

    widget.document.name = controllers['name']!.value.text;
    widget.document.root = _rootSelectController.values.single;
    widget.document.type = _typeSelectController.values.single;
    widget.document.parentID = _parentSelectController.values.singleOrNull?.id ?? 0;

    final Result<Account> result = await widget.onSubmit();
    if (!result.isEmpty && mounted) {
      // TODO: try to replace this with a DocumentView builder and use pushReplace() instead of pop().
      Navigator.of(context).pop<Result<Account>>(result);
    }
  }
}
