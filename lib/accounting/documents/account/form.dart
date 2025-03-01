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
  final Future<bool> Function(Account) onSubmit;

  @override
  State<StatefulWidget> createState() => _NewState();
}

class _NewState extends State<AccountForm> with SingleTickerProviderStateMixin implements DocumentForm {

  List<Account> parents = [];

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
    updateParentsOptions();
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
              initialValue: _rootSelectController.value.firstOrNull,
              options: AccountRoot.values.toList(),
              flex: 1,
              label: "Root Type",
              prefix: FIcon(FAssets.icons.folderRoot),
              valueBuilder: (context, root) => Text(root.toString()),
              controller: _rootSelectController,
              tileSelectBuilder: (context, value) => FTile(
                prefixIcon: FIcon(FAssets.icons.folderRoot),
                title: Text(value.name, style: theme.typography.base),
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
              controller: _typeSelectController,
              tileSelectBuilder: (context, value) => FTile(
                prefixIcon: FIcon(FAssets.icons.fileType),
                title: Text(value.name, style: theme.typography.base),
                onPress: () {
                  Navigator.pop(context, value);
                },
              ),
            )
          ]
        ),
        SizedBox(height: 8),
        Row(
          spacing: 8,
          children: [
            AvertSelect<Account>(
              flex: 1,
              options: parents,
              enabled: true,
              label: "Parent",
              prefix: FIcon(FAssets.icons.fileType),
              valueBuilder: (context, account) => Text(account?.name ?? "No Account Available"),
              controller: _parentSelectController,
              tileSelectBuilder: (context, value) => FTile(
                prefixIcon: FIcon(FAssets.icons.fileType),
                title: Text(value.name, style: theme.typography.base),
                onPress: () => Navigator.pop(context, value),
              ),
            ),
            AvertToggle(
              label: "is Group",
              initialValue: widget.document.isGroup,
              onChange: (value) => widget.document.isGroup = value,
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
    if (isReallyDirty == isDirty) return;
    setState(() => isDirty = isReallyDirty );
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

    final bool success = await widget.onSubmit(widget.document);

    if (success && mounted) Navigator.of(context).pop();

  }

  void updateParentsOptions() {
    Account.fetchParents(
      widget.document.profile,
      _rootSelectController.value.firstOrNull,
      _typeSelectController.value.firstOrNull,
    ).then((accounts) {
      if (accounts.isNotEmpty) {
        setState(() => parents = accounts);
      }
    });
  }
}
