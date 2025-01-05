import "package:avert/core/core.dart";
import "package:forui/forui.dart";
import "package:avert/core/utils/ui.dart";

class AvertDocumentView<T extends Document> extends StatelessWidget {
  const AvertDocumentView({super.key,
    required this.name,
    required this.title,
    required this.controller,
    required this.deleteDocument,
    required this.result,
    this.image,
    this.subtitle,
    this.menuActions,
    this.leading,
    this.content,
    this.tabview,
    this.editDocument,
    this.onImagePress,
  });

  final String name, title;
  final String? subtitle;
  final Widget?  leading, content;
  final List<FTileGroupMixin<FTileMixin>>? menuActions;
  final FPopoverController controller;
  final FTabs? tabview;
  final ImageProvider<Object>? image;
  final Function()? editDocument, deleteDocument, onImagePress;
  final Result<T>? result;

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
    printInfo(title);

    Widget contentHeading = Row(
      children: [
        FButton.raw(
          onPress: onImagePress,
          child: Container(
            alignment: Alignment.center,
            height: 150,
            width: 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              color: theme.avatarStyle.backgroundColor,
              image: image != null ? DecorationImage(
                image: image!,
                fit: BoxFit.cover,
              ) : null,
            ),
            clipBehavior: Clip.hardEdge,
            child: Text(getAcronym(title),
              style: theme.typography.xl6
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                style: theme.cardStyle.contentStyle.titleTextStyle
              ),
              Text(subtitle ?? "" ,
                style: theme.cardStyle.contentStyle.subtitleTextStyle
              ),
            ],
          ),
        ),
      ]
    );

    return PopScope<Result<T>>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        Navigator.of(context).pop<Result<T>>(result);
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
                onPress: () => Navigator.of(context).maybePop<Result<T>>(result),
              ),
            ],
            suffixActions: [
              FHeaderAction(
                icon: FIcon(FAssets.icons.filePenLine),
                onPress: editDocument,
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
              Padding(
                padding: EdgeInsets.only(top: 16, left: 16),
                child:contentHeading,
              ),
              Container(child: content),
              FDivider(),
              Container(child: tabview),
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
              onPress: () => Navigator.of(context).maybePop<Result<T>>(Result(null)),
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
              Navigator.of(context).pop<Result<T>>(Result.empty());
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
