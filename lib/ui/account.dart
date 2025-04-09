import "package:avert/docs/accounting/account.dart";
import "package:avert/docs/document.dart";
import "package:avert/docs/profile.dart";

import "package:avert/ui/components/document.dart";
import "package:avert/ui/components/input.dart";
import "package:avert/ui/components/select.dart";
import "package:avert/ui/components/toggle.dart";
import "package:avert/ui/core.dart";

import "package:avert/utils/common.dart";
import "package:avert/utils/logger.dart";
import "package:avert/utils/ui.dart";

import "package:flutter/material.dart";
import "package:forui/forui.dart";

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

class _NewState extends State<AccountForm> with TickerProviderStateMixin implements DocumentForm {
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
            Flexible(
              child: AvertSelect<AccountRoot>(
                options: AccountRoot.values.toList(),
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
            ),
            Flexible(
              child: AvertSelect<AccountType>(
                options: AccountType.values.toList(),
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
              ),
            )
          ]
        ),
        SizedBox(height: 8),
        Row(
          spacing: 8,
          children: [
            Flexible(
              child: AvertSelect<Account>(
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

class AccountTile extends StatefulWidget {
  const AccountTile({super.key,
    required this.document,
    required this.profile,
    required this.removeDocument,
  });

  final Account document;
  final Profile profile;
  final void Function(Account) removeDocument;

  @override
  State<StatefulWidget> createState() => _TileState();
}

class _TileState extends State<AccountTile> {
  late String _name = widget.document.name;
  late String _root = widget.document.root.toString();
  late SvgAsset _icon = widget.document.isGroup ? FAssets.icons.folder : FAssets.icons.file;

  @override
  Widget build(BuildContext context) {
    printTrack("build account tile with name of :${widget.document.name}");
    final FThemeData theme = FTheme.of(context);
    return ListTile(
      leading: FIcon(_icon),
      subtitle: Text(_root, style: theme.typography.sm),
      title: Text(_name, style: theme.typography.base),
      onTap: _viewAccount,
    );
  }

  void _viewAccount() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AccountView(
          document: widget.document,
        ),
      )
    );

    if (widget.document.action == DocAction.none) return;

    switch (widget.document.action) {
      case DocAction.update: {
        setState(() => _name = widget.document.name);
      } break;
      case DocAction.delete: {
        widget.removeDocument(widget.document);
      } break;
      default: break;
    }
  }
}

class AccountView extends StatefulWidget {
  const AccountView({ super.key,
    required this.document,
  });

  final Account document;

  @override
  State<StatefulWidget> createState() => _ViewState();
}

class _ViewState extends State<AccountView> with TickerProviderStateMixin implements DocumentView<Account>  {
  late final FPopoverController _controller;
  List<Account> children = [];

  @override
  late Account document = widget.document;

  @override
  void initState() {
    super.initState();
    _controller = FPopoverController(vsync: this);
    if (document.isGroup) {
      document.fetchChildren().then((value) {
        if (value.isEmpty) return;
        setState(() => children = value);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    printTrack("Building Account Document View");
    final FThemeData theme = FTheme.of(context);
    final FCardContentStyle contentStyle = theme.cardStyle.contentStyle;

    final SvgAsset icon = document.isGroup ? FAssets.icons.folder : FAssets.icons.file;
    final FLabelStateStyles textStyle = theme.textFieldStyle.labelStyle.state;
    final Widget? parent = document.parentID == 0 ? Column( children: [
      Text("Parent:", style: textStyle.enabledStyle.labelTextStyle),
      SizedBox(height: 4),
      Row(children: [
        FIcon(FAssets.icons.folder),
        SizedBox(width: 8),
        Text("Parent Name", style: theme.typography.sm),
      ]),
    ]) : null;

    final List<Widget> header = [
      Row (
        children: [
          FIcon(icon, size: 48),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(document.name, style: contentStyle.titleTextStyle),
              Text(document.root.toString(), style: contentStyle.subtitleTextStyle),
            ],
          ),
        ],
      ),
      SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column( children: [
            Text( "Type:", style: textStyle.enabledStyle.labelTextStyle),
            SizedBox(height: 4),
            FBadge(
              label: Text(document.type.displayName),
              style: document.type == AccountType.none ?  FBadgeStyle.secondary : FBadgeStyle.primary ),
          ]),
          SizedBox(width: 8),
          Column( children: [
            Text( "Group:", style: textStyle.enabledStyle.labelTextStyle),
            SizedBox(height: 4),
            FBadge(
              label: Text(document.isGroup?"Yes":"No"),
              style: document.isGroup ? FBadgeStyle.primary :FBadgeStyle.destructive
            ),
          ]),
          SizedBox(width: 8),
          Container(child: parent),
        ]
      ),
    ];
    final Widget parentDetails = children.isNotEmpty ? Container(
      decoration: theme.cardStyle.decoration,
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Child Accounts",
            style: theme.typography.lg.copyWith(fontWeight: FontWeight.w600),
          ),
          ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: children.length,
            itemBuilder: (context, index) {
              Account document = children[index];
              return AccountTile(
                key: ObjectKey(document),
                document: document,
                profile: document.profile,
                removeDocument: (account) {
                  if (children.contains(account)) {
                    setState(() => children.remove(document));
                  }
                },
              );
            },
          )
        ]
      ),
    ) : Container(
      decoration: theme.cardStyle.decoration,
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded( flex: 1, child: Text(
            "No Child Available!",
            style: theme.typography.base,
            textAlign: TextAlign.center,
          ))
        ]
      ),
    );
    return AvertDocumentView<Account>(
      controller: _controller,
      name: "Account",
      header: header,
      editDocument: editDocument,
      deleteDocument: deleteDocument,
      content: Column(
        children: [
          SizedBox(child: document.isGroup ? parentDetails : null),
        ]
      ),
    );
  }

  @override
  void editDocument() async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) => AccountForm(
        document: document,
        onSubmit: _onEdit,
      ),
    ));

    if (document.action == DocAction.none) return;
    if (document.action == DocAction.update) {
      setState(() => document = document);
      throw UnimplementedError("Should update the View");
    }
  }

  Future<bool> _onEdit(Account document) async  {
    String msg = "Error writing Account to the database!";
    final bool success = await document.update();
    if (success) msg = "Successfully changed Account details";
    if (mounted) notify(context, msg);
    return success;
  }

  Future<bool?> _confirmDelete() {
    return showAdaptiveDialog<bool>(
      context: context,
      builder: (BuildContext context) => FDialog(
        direction: Axis.horizontal,
        title: Text("Delete '${document.name}'?"),
        body: const Text("Are you sure you want to delete this Account?"),
        actions: <Widget>[
          FButton(
            label: const Text("No"),
            style: FButtonStyle.outline,
            onPress: () {
              Navigator.of(context).pop(false);
            },
          ),
          FButton(
            style: FButtonStyle.destructive,
            label: const Text("Yes"),
            onPress: () {
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    );
  }

  @override
  Future<void> deleteDocument() async {
    bool hasChild = await document.hasChild;
    if (hasChild) {
      if (mounted) notify(context, "Could not delete: '${document.name}' has child accounts");
      return;
    }
    final bool shouldDelete = await _confirmDelete() ?? false;

    if (shouldDelete) {
      final bool success = await document.delete();

      if (!success) {
        if (mounted) notify(context, "Could not delete: '${document.name}' can't be deteled in database!");
        return;
      }
      printWarn("Deleting Account:${document.name} with id of: ${widget.document.id}");
      if (mounted) Navigator.of(context).pop();
    }
  }
}

