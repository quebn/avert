import "package:avert/core/components/avert_document.dart";
import "package:avert/core/components/avert_input.dart";
import "package:avert/core/core.dart";
import "package:forui/forui.dart";

class ProfileForm extends StatefulWidget {
  const ProfileForm({super.key,
    required this.document,
    required this.onSubmit,
  });

  final Profile document;
  final Future<bool> Function() onSubmit;

  @override
  State<StatefulWidget> createState() => _NewState();
}

class _NewState extends State<ProfileForm> with SingleTickerProviderStateMixin implements DocumentForm {

  @override
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  final Map<String, TextEditingController> controllers = {
    'name': TextEditingController(),
  };

  @override
  bool isDirty = false;

  @override
  String? errMsg;

  @override
  void dispose() {
    super.dispose();
    for (TextEditingController c in controllers.values) {
      c.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    printTrack("Building ProfileDocumentForm");
    FThemeData theme = FTheme.of(context);
    return AvertDocumentForm(
      formKey: formKey,
      title: Text("${isNew(widget.document) ? "New" : "Edit"} Profile",),
      contents: [
        AvertInput.text(
          label: "Name",
          hint: "Ex. Acme Inc.",
          controller: controllers['name']!,
          required: true,
          forceErrMsg: errMsg,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          initialValue: widget.document.name,
          onChange: (value) => onValueChange((){
            return value != widget.document.name;
          }),
        ),
        FDivider(),
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

  @override
  void onValueChange(bool Function() isDirtyCallback) {
    final bool isReallyDirty = isDirtyCallback();
    if (isReallyDirty == isDirty) {
      return;
    }
    printTrack("Setting state of isdirty = $isReallyDirty");
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

    bool shouldPop = await widget.onSubmit();

    if (shouldPop && mounted) {
      Navigator.of(context).pop<Profile>(widget.document);
    }
  }
}
