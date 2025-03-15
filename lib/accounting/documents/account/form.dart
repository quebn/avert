import "package:avert/core/components/document.dart";
import "package:avert/core/components/input.dart";
import "package:avert/core/components/select.dart";
import "package:avert/core/components/toggle.dart";
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
  Account get document => widget.document;
  List<Account> parents = [];

  @override
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late final AvertSelectController<AccountRoot> _rootSelectController;
  late final AvertSelectController<AccountType> _typeSelectController;
  late final AvertSelectController<Account> _parentSelectController;

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
    _rootSelectController = AvertSelectController<AccountRoot>(
      value: AccountRoot.asset,
      onUpdate: (value, didChange) {
        if (didChange) _updateParentsOptions();
      },
    );
    _typeSelectController = AvertSelectController<AccountType>(
      value: AccountType.none,
      onUpdate: (value, didChange) {
        if (didChange) _updateParentsOptions();
      },
    );
    _parentSelectController = AvertSelectController<Account>();
    _updateParentsOptions();
  }

  @override
  void dispose() {
    super.dispose();
    for (TextEditingController controller in controllers.values) {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    printTrack("Building AccountDocumentForm");
    final FThemeData theme = FTheme.of(context);
    final TextStyle selectValueStyle = theme.textFieldStyle.disabledStyle.labelTextStyle;
    return AvertDocumentForm<Account>(
      formKey: formKey,
      title: Text("${isNew(document) ? "New" : "Edit"} Account",),
      contents: [
        AvertInput.text(
          label: "Name",
          hint: "Ex. Cash Account",
          controller: controllers['name']!,
          required: true,
          forceErrMsg: errMsg,
          initialValue: document.name,
          onChange: (value) => onValueChange(() {
            return value != document.name;
          }),
        ),
        SizedBox(height: 8),
        Row(
          spacing: 8,
          children: [
            AvertSelect<AccountRoot>(
              options: AccountRoot.values.toList(),
              flex: 1,
              label: "Root Type",
              prefix: FIcon(FAssets.icons.folderRoot),
              required: true,
              valueBuilder: (context, root) => Text(root.toString()),
              controller: _rootSelectController,
              tileSelectBuilder: (context, value) => AvertSelectTile<AccountRoot>(
                selected: _rootSelectController.value == value,
                value: value,
                prefix: FIcon(FAssets.icons.folderRoot),
                title: Text(value.toString(), style: theme.typography.base),
              ),
            ),
            AvertSelect<AccountType>(
              options: AccountType.values.toList(),
              flex: 1,
              label: "Account Type",
              prefix: FIcon(FAssets.icons.fileType),
              required: true,
              valueBuilder: (context, type) => Text(type?.displayName ?? "No Type Found"),
              controller: _typeSelectController,
              tileSelectBuilder: (context, value) => AvertSelectTile<AccountType>(
                selected: _typeSelectController.value == value,
                value: value,
                prefix: FIcon(FAssets.icons.fileType),
                title: Text(value.displayName, style: theme.typography.base),
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
              label: "Parent",
              prefix: FIcon(FAssets.icons.fileType),
              valueBuilder: (context, account) {
                return (account != null)
                ? Text(account.name)
                : Text("None", style: selectValueStyle);
              },
              validator: _parentValidator,
              controller: _parentSelectController,
              tileSelectBuilder: (context, value) => AvertSelectTile<Account>(
                selected: _parentSelectController.value == value,
                value: value,
                prefix: FIcon(FAssets.icons.fileType),
                title: Text(value.name, style: theme.typography.base),
                subtitle: Text(value.type.toString(), style: theme.typography.sm),
              ),
            ),
            AvertToggle(
              label: "is Group",
              initialValue: document.isGroup,
              onChange: (value) {
                if (!isNew(document)) {
                }
                document.isGroup = value;
              },
            ),
          ]
        ),
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
    if (!isValid) return;
    FocusScope.of(context).requestFocus(FocusNode());

    document.name = controllers['name']!.value.text;
    document.root = _rootSelectController.value!;
    document.type = _typeSelectController.value!;
    document.parentID = _parentSelectController.value?.id ?? 0;

    final bool success = await widget.onSubmit(document);
    if (success && mounted) Navigator.of(context).pop<Account>(document);
  }

  void _updateParentsOptions() {
    Account.fetchParents(
      document.profile,
      _rootSelectController.value,
      _typeSelectController.value,
    ).then((accounts) {
      setState(() {
        _parentSelectController.update(null);
        parents = accounts;
      });
      printAssert(_parentSelectController.value == null, "Failed to clear!");
    });
  }

  String? _parentValidator(Account? value) {
    if (value == null) return null;
    final AccountType type = _typeSelectController.value!;
    final AccountRoot root = _rootSelectController.value!;
    if (value.root != root && value.type != type) {
      return "Parent '${value.name}' is not valid! root should be '${root.toString()}' and type should be '${type.displayName}'";
    }
    return null;
  }
}
