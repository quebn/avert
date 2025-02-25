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
    required this.onSubmit,
  });

  final Account document;
  final Future<Result<Account>> Function(Account) onSubmit;

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
    final FThemeData theme = FTheme.of(context);
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
              // controller: _rootSelectController,
              initialValue: _rootSelectController.value.firstOrNull,
              options: AccountRoot.values.toList(),
              flex: 1,
              label: "Root Type",
              prefix: FIcon(FAssets.icons.folderRoot),
              valueBuilder: (context, root) => Text(root.toString()),
              tileSelectBuilder: (context, value) => FTile(
                prefixIcon: FIcon(FAssets.icons.folderRoot),
                title: Text(value.name, style: theme.typography.base),
                // style: theme.tileGroupStyle.tileStyle.copyWith(border: Border.all(width: 0)),
                enabled: value == _rootSelectController.value.firstOrNull,
                onPress: () => Navigator.pop(context, value),
              ),
            ),
            AvertSelect<AccountType>(
              initialValue: _typeSelectController.value.firstOrNull,
              options: AccountType.values.toList(),
              flex: 1,
              label: "Account Type",
              prefix: FIcon(FAssets.icons.fileType),
              valueBuilder: (context, type) => Text(type?.displayName ?? "No Type Found"),
              tileSelectBuilder: (context, value) => FTile(
                prefixIcon: FIcon(FAssets.icons.fileType),
                title: Text(value.name, style: theme.typography.base),
                // style: theme.tileGroupStyle.tileStyle.copyWith(border: Border.all(width: 0)),
                enabled: value == _typeSelectController.value.firstOrNull,
                onPress: () => Navigator.pop(context, value),
              ),
            )
          ]
        ),
        SizedBox(height: 8),
        Row(
          spacing: 8,
          children: [
            AvertSelect<Account>.queryOptions(
              flex: 1,
              optionsQuery: null, // TODO: create query for this
              label: "Parent",
              prefix: FIcon(FAssets.icons.fileType),
              valueBuilder: (context, type) => Text(type?.name ?? "No Account Available"),
              tileSelectBuilder: (context, value) => FTile(
                prefixIcon: FIcon(FAssets.icons.fileType),
                title: Text(value.name, style: theme.typography.base),
                // style: theme.tileGroupStyle.tileStyle.copyWith(border: Border.all(width: 0)),
                enabled: value == _parentSelectController.value.firstOrNull,
                onPress: () => Navigator.pop(context, value),
              ),
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
    widget.document.root = _rootSelectController.value.single;
    widget.document.type = _typeSelectController.value.single;
    widget.document.parentID = _parentSelectController.value.singleOrNull?.id ?? 0;

    final Result<Account> result = await widget.onSubmit(widget.document);

    if (!result.isEmpty && mounted) {
       Navigator.of(context).pop<Result<Account>>(result);
    }
  }
}
