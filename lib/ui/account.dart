import "package:avert/docs/accounting.dart";
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
  State<StatefulWidget> createState() => _FormState();
}

class _FormState extends State<AccountForm> with TickerProviderStateMixin implements DocumentForm {
  Account get document => widget.document;
  List<Account> parents = [];

  @override
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late final AvertSelectController<AccountRoot> rootController;
  late final AvertSelectController<AccountType> typeController;
  late final AvertSelectController<Account> parentController;

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
    rootController = AvertSelectController<AccountRoot>(
      value: document.root,
      onUpdate: (value, didChange) {
        if (didChange) updateParentsOptions();
      },
    );
    typeController = AvertSelectController<AccountType>(
      value: document.type,
      onUpdate: (value, didChange) {
        if (didChange) updateParentsOptions();
      },
    );
    parentController = AvertSelectController<Account>();
    updateParentsOptions();
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
          controller: controllers["name"]!,
          required: true,
          forceErrMsg: errMsg,
          initialValue: document.name,
          onChange: (value) => onValueChange(setState, this, () {
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
                onChange: (v) => onValueChange(setState, this, () {
                  return v != document.root;
                }),
                valueBuilder: (context, root) => Text(root.toString()),
                controller: rootController,
                tileSelectBuilder: (context, value) => AvertSelectTile<AccountRoot>(
                  selected: rootController.value == value,
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
                onChange: (v) => onValueChange(setState, this, () {
                  return v != document.type;
                }),
                valueBuilder: (context, type) => Text(type?.displayName ?? "No Type Found"),
                controller: typeController,
                tileSelectBuilder: (context, value) => AvertSelectTile<AccountType>(
                  selected: typeController.value == value,
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
                validator: parentValidator,
                controller: parentController,
                tileSelectBuilder: (context, value) => AvertSelectTile<Account>(
                  selected: parentController.value == value,
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

  // @override
  // void onValueChange(bool Function() isDirtyCallback) {
  //   final bool isReallyDirty = isDirtyCallback();
  //   if (isReallyDirty == isDirty) return;
  //   setState(() => isDirty = isReallyDirty );
  // }

  @override
  void submitDocument() async {
    final bool isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) return;
    FocusScope.of(context).requestFocus(FocusNode());

    document.name = controllers["name"]!.value.text;
    document.root = rootController.value!;
    document.type = typeController.value!;
    document.parentID = parentController.value?.id ?? 0;

    final bool success = await widget.onSubmit(document);
    if (success && mounted) Navigator.of(context).pop<Account>(document);
  }

  void updateParentsOptions() {
    Account.fetchParents(
      document.profile,
      rootController.value,
      typeController.value,
    ).then((accounts) {
      setState(() {
        parentController.update(null);
        parents = accounts;
      });
      printAssert(parentController.value == null, "Failed to clear!");
    });
  }

  String? parentValidator(Account? value) {
    if (value == null) return null;
    final AccountType type = typeController.value!;
    final AccountRoot root = rootController.value!;
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
  int updateCount = 0;
  Account get document => widget.document;
  late SvgAsset icon = widget.document.isGroup ? FAssets.icons.folder : FAssets.icons.file;

  @override
  Widget build(BuildContext context) {
    printTrack("build account tile with name of :${widget.document.name}");
    final FThemeData theme = FTheme.of(context);
    return ListTile(
      leading: FIcon(icon),
      subtitle: Text(document.root.toString(), style: theme.typography.sm),
      title: Text(document.name, style: theme.typography.base),
      onTap: view,
    );
  }

  void view() async {
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
        setState(() => updateCount++);
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
  late final FPopoverController controller;
  int updateCount = 0;

  @override
  Account get document => widget.document;

  @override
  void initState() {
    super.initState();
    controller = FPopoverController(vsync: this);
    if (document.isGroup) {
      document.fetchChildren().then((success) {
        if (!success) return;
        setState(() => updateCount++);
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    printTrack("Building Account Document View");
    final FThemeData theme = FTheme.of(context);
    final FCardContentStyle contentStyle = theme.cardStyle.contentStyle;

    final SvgAsset icon = document.isGroup ? FAssets.icons.folder : FAssets.icons.file;
    final FLabelStateStyles textStyle = theme.textFieldStyle.labelStyle.state;
    final Widget? parent = document.parentID == 0 ? null : Column(children: [
      Text("Parent:", style: textStyle.enabledStyle.labelTextStyle),
      SizedBox(height: 4),
      Row( children: [
        FIcon(FAssets.icons.folder),
        SizedBox(width: 8),
        Text("Parent Name", style: theme.typography.sm),
      ]),
    ]);

    final List<Widget> header = [
      Row(
        mainAxisSize: MainAxisSize.max,
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
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 8,
        children: [
          // Column(children: [
          //   Text("Type:", style: textStyle.enabledStyle.labelTextStyle),
          //   SizedBox(height: 4),
          //   FBadge(
          //     label: Text(document.type.displayName),
          //     style: document.type == AccountType.none ?  FBadgeStyle.secondary : FBadgeStyle.primary ),
          // ]),
          // Column(children: [
          //   Text("Group:", style: textStyle.enabledStyle.labelTextStyle),
          //   SizedBox(height: 4),
          //   FBadge(
          //     label: Text(document.isGroup?"Yes":"No"),
          //     style: document.isGroup ? FBadgeStyle.primary :FBadgeStyle.destructive
          //   ),
          // ]),
          Container(child: parent),
        ]
      ),
    ];
    return AvertDocumentView<Account>(
      controller: controller,
      name: "Account",
      header: header,
      editDocument: editDocument,
      deleteDocument: deleteDocument,
      content: Column(
        children: [
          // TODO: display the ff.
          // - [ ] total debit or credit valus of entries of this account.
          // - [ ] when click should display a popup to list all the entry tiles.
          AccountTotalBalance(account: document),
          SizedBox(child: document.isGroup ? childrenDetails() : null),
        ]
      ),
    );
  }

  @override
  void editDocument() async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) => AccountForm(
        document: document,
        onSubmit: onEdit,
      ),
    ));

    if (document.action == DocAction.none) return;
    if (document.action == DocAction.update) {
      setState(() => updateCount++);
    }
  }

  Future<bool> onEdit(Account document) async  {
    final String? error = await document.update();
    final String msg = error ?? "Successfully changed Account details";
    if (mounted) notify(context, msg);
    return error == null;
  }

  Future<bool?> confirmDelete() {
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
    final bool shouldDelete = await confirmDelete() ?? false;

    if (shouldDelete) {
      final String? error = await document.delete();

      if (error != null) {
        if (mounted) notify(context, error);
        return;
      }
      printWarn("Deleting Account:${document.name} with id of: ${widget.document.id}");
      if (mounted) Navigator.of(context).pop();
    }
  }

  Widget childrenDetails() => document.children != null && document.children!.isNotEmpty ? Container(
      decoration: context.theme.cardStyle.decoration,
      padding: EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Child Accounts",
            style: context.theme.typography.lg.copyWith(
              fontWeight: FontWeight.w600
            ),
          ),
          ListView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: document.children!.length,
            itemBuilder: (context, index) {
              Account doc = document.children![index];
              return AccountTile(
                key: ObjectKey(doc),
                document: doc,
                profile: doc.profile,
                removeDocument: (account) {
                  if (document.children!.contains(account)) {
                    setState(() => document.children!.remove(doc));
                  }
                },
              );
            },
          )
        ]
      ),
    ) : Container(
      decoration: context.theme.cardStyle.decoration,
      padding: EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded( flex: 1, child: Text(
            "No Child Available!",
            style: context.theme.typography.base,
            textAlign: TextAlign.center,
          ))
        ]
      ),
    );
}

class AccountTotalBalance extends StatefulWidget {
  const AccountTotalBalance({
    super.key,
    required this.account,
  });

  final Account account;

  @override
  State<StatefulWidget> createState() => _TotalBalanceState();
}

class _TotalBalanceState extends State<AccountTotalBalance> {
  Account get document => widget.account;
  double total = 0;

  @override
  void initState() {
    super.initState();
    document.getTotalBalance().then((v) {
      if (v == total) return;
      setState(() => total = v);
    });
  }

  @override
  Widget build(BuildContext context) {
    final FThemeData theme = FTheme.of(context);
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.only(bottom: 8),
        padding: EdgeInsets.all(8),
        child: FCard.raw(
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: [
                Text("Total Value", style: theme.typography.base,)
              ]
            )
          )
        )
      )
    );
  }
}
