import "package:avert/docs/core.dart";
import "package:avert/utils/common.dart";
import "package:flutter/material.dart";
import "package:forui/forui.dart";
import "package:avert/utils/ui.dart";

class AvertDocumentView<T extends Document> extends StatelessWidget {
  const AvertDocumentView({
    super.key,
    required this.name,
    required this.header,
    required this.controller,
    required this.deleteDocument,
    this.prefix,
    this.enablePrefix = false,
    this.menuActions,
    this.leading,
    this.content,
    this.editDocument,
    // this.onImagePress,
  });

  final String name;
  final Widget? leading, content;
  final List<Widget> header;
  final Widget? prefix;
  final bool enablePrefix;
  final List<FTileGroupMixin<FTileMixin>>? menuActions;
  final FPopoverController controller;
  final Function()? editDocument, deleteDocument;

  @override
  Widget build(BuildContext context) {
    final FThemeData theme = FTheme.of(context);

    final List<FTileGroupMixin<FTileMixin>> actionsGroups = menuActions ?? [];
    actionsGroups.add(
      FTileGroup(
        children: [
          FTile(
            enabled: deleteDocument != null,
            prefixIcon: FIcon(FAssets.icons.trash2),
            title: Text("Delete $name"),
            onPress: deleteDocument,
          ),
        ],
      )
    );
    final Widget prfx = prefix ?? FButton.raw(
      onPress: null, // TODO: implement later
      child: Container(
        alignment: Alignment.center,
        height: 150,
        width: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          color: theme.avatarStyle.backgroundColor,
          // TODO: implement later
          // image: image != null ? DecorationImage(
            //   image: image!,
            //   fit: BoxFit.cover,
            // ) : null,
          ),
          clipBehavior: Clip.hardEdge,
          child: Text(getAcronym(name),
          style: theme.typography.xl6
        ),
      ),
    );

    final Widget contentHeading = Row(
      children: [
        SizedBox(child: enablePrefix || prefix != null ? prfx : null),
        Padding(
          padding: EdgeInsets.only(left: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: header,
          ),
        ),
      ]
    );
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.of(context).pop();
      },
      child: Scaffold(
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
                onPress: editDocument,
              ),
              FPopoverMenu(
                popoverController: controller,
                menu: actionsGroups,
                child: FHeaderAction(
                  icon: FIcon(FAssets.icons.ellipsisVertical,
                  size: 28,
                ),
                onPress: controller.toggle,
              ),
            ),
          ],
        ),
        content:Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 16, left: 16),
              child:contentHeading,
            ),
            FDivider(),
            Container(child: content),
          ]
        ),
      ),
    ),
  );
  }
}

class AvertDocumentForm<T extends Document> extends StatelessWidget {
  const AvertDocumentForm({super.key,
    required this.title,
    required this.contents,
    this.floatingActionButton,
    this.leading,
    this.formKey,
    this.actions,
    this.isDirty = true,
    this.resizeToAvoidBottomInset = false,
  });

  final Widget title;
  final Widget? floatingActionButton;
  final List<Widget> contents;
  final GlobalKey<FormState>? formKey;
  final Widget? leading;
  final List<Widget>? actions;
  final bool isDirty;
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
          onPopInvokedWithResult: (didPop, _) async {
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
