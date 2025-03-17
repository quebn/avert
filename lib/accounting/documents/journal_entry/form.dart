import 'package:avert/accounting/documents/journal_entry/document.dart';
import 'package:avert/core/components/document.dart';
import 'package:avert/core/components/input.dart';
import 'package:avert/core/core.dart';

class JournalEntryForm extends StatefulWidget {
  const JournalEntryForm({
    super.key,
    required this.document,
    required this.onSubmit,
  });

  final JournalEntry document;
  final Future<bool> Function(JournalEntry) onSubmit;

  @override
  State<StatefulWidget> createState() => _FormState();
}

class _FormState extends State<JournalEntryForm> implements DocumentForm {

  JournalEntry get document => widget.document;

  @override
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  final Map<String, TextEditingController> controllers = {
    'name': TextEditingController(),
  };

  @override
  String? errMsg;

  @override
  bool isDirty = false;

  @override
  void dispose() {
    super.dispose();
    for (TextEditingController controller in controllers.values) {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AvertDocumentForm(
      title: Text("${isNew(document) ? "New" : "Edit"} Journal Entry",),
      contents: [
        AvertInput.text(
          label: "Name",
          hint: "Ex. Payment of Supplies",
          controller: controllers['name']!,
          required: true,
          forceErrMsg: errMsg,
          initialValue: document.name,
          onChange: (value) => onValueChange(() {
            return value != document.name;
          }),
        ),
        // TODO: date time picker
        // TODO: list
      ],
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
    // TODO: date
    // TODO: entries

    final bool success = await widget.onSubmit(document);
    if (success && mounted) Navigator.of(context).pop<JournalEntry>(document);
  }
}
