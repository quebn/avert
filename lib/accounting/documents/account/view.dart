import "package:avert/core/components/document.dart";
import "package:avert/core/core.dart";
import "package:avert/core/utils/ui.dart";
import "package:forui/forui.dart";

import "document.dart";
import "form.dart";
import "tile.dart";

class AccountView extends StatefulWidget {
  const AccountView({ super.key,
    required this.document,
  });

  final Account document;

  @override
  State<StatefulWidget> createState() => _ViewState();
}

class _ViewState extends State<AccountView> with SingleTickerProviderStateMixin implements DocumentView<Account>  {
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
