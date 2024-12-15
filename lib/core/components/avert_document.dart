import "package:flutter/material.dart";
import "package:forui/forui.dart";
import "package:avert/core/utils/ui.dart";

class AvertDocumentView extends StatelessWidget {
  const AvertDocumentView({super.key,
    required this.name,
    required this.title,
    required this.controller,
    //this.image,
    this.subtitle,
    this.menuActions,
    this.leading,
    this.onEdit,
    this.onDelete,
    this.content,
    this.tabview,
  });

  final String name;
  final Widget? /*image,*/ title, subtitle, leading, content;
  final List<FTileGroupMixin<FTileMixin>>? menuActions;
  final FPopoverController controller;
  final FTabs? tabview;
  final Function()? onEdit, onDelete;

  @override
  Widget build(BuildContext context) {
    final List<FTileGroupMixin<FTileMixin>> actionsGroups = menuActions ?? [];
    actionsGroups.add(
      FTileGroup(
        children: [
          FTile(
            enabled: onDelete != null,
            prefixIcon: FIcon(FAssets.icons.trash2),
            title: const Text("Delete Document"),
            onPress: onDelete,
          ),
        ],
      )
    );
    FThemeData theme = FTheme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      resizeToAvoidBottomInset: false,
      body: FScaffold(
        header: FHeader.nested(
          title: Text(name),
          style: theme.headerStyle.nestedStyle,
          prefixActions:[
            leading ?? FHeaderAction(
              icon: Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: FIcon(FAssets.icons.chevronLeft),
              ),
              onPress: () => Navigator.of(context).maybePop(),
            ),
          ],
          suffixActions: [
            FHeaderAction(
              icon: FIcon(FAssets.icons.filePenLine),
              onPress: onEdit,
            ),
            FPopoverMenu.tappable(
              controller: controller,
              menu: actionsGroups,
              child: FIcon(FAssets.icons.ellipsisVertical,
                size: 28,
              ),
            ),
          ],
        ),
        content:Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(child: content),
              Container(child: tabview),
            ]
        ),
      ),
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
    this.tabview,
    this.resizeToAvoidBottomInset = false,
  });

  final Widget title;
  final Widget? floatingActionButton;
  final List<Widget> contents;
  final GlobalKey<FormState>? formKey;
  final Widget? leading;
  final List<Widget>? actions;
  final bool isDirty;
  final FTabs? tabview;
  final bool resizeToAvoidBottomInset;

  @override
  Widget build(BuildContext context) {
    final FThemeData theme = FTheme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      body: FScaffold(
        header: FHeader.nested(
          suffixActions: actions ?? [],
          prefixActions: [
            leading ?? FHeaderAction(
              icon: Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: FIcon(FAssets.icons.chevronLeft),
              ),
              onPress: () => Navigator.of(context).maybePop(),
            ),
          ],
          style: theme.headerStyle.nestedStyle,
          title: const Text("Avert",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
            ),
          ),
        ),
        content: Form(
          key: formKey,
          canPop: !isDirty,
          onPopInvokedWithResult: (bool didPop, Object? value) async {
            if (didPop) return;
            final bool shouldPop = await confirm(context) ?? false;
            if (shouldPop && context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: FCard(
            title: Container(
              alignment: Alignment.center,
              child: title,
            ),
            child: Column(
              children: [
                Column(
                  children: contents,
                ),
                Container(
                  child: tabview,
                ),
              ]
            ),
          ),
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
