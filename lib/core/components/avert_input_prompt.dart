import "package:avert/core/components/avert_input.dart";
import "package:avert/core/core.dart";


class AvertInputPrompt extends StatefulWidget {
  const AvertInputPrompt({super.key,
    required this.text,
    required this.controller,
    this.viewOnly = false,
    this.style,
    this.onValueChange,
  });

  final TextEditingController controller;
  final String text;
  final TextStyle? style;
  final bool viewOnly;
  final void Function()? onValueChange;

  @override
  State<StatefulWidget> createState() => _InputPromptState();
}

class _InputPromptState extends State<AvertInputPrompt> {

  late String text = widget.text;
  String? userErrMsg;

  @override
  Widget build(BuildContext context) {
    printTrack("Building Input Prompt");
    return Center(
      child: TextButton(
        onPressed: () async {
          if (widget.viewOnly) return;
          final shouldUpdate = await promptEditField() ?? false;
          if (shouldUpdate) {
            if (widget.onValueChange != null) widget.onValueChange!();
            setState(() => text = widget.controller.value.text);
          }
        },
        child: Text(text,
          style: widget.style,
        ),
      ),
    );
  }

Future<bool?> promptEditField() {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Edit Field",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: AvertInput.alphanumeric(
          autofocus: true,
          name:"Username",
          controller: widget.controller,
          required: true,
          forceErrMsg: userErrMsg,
          onChanged: (String? value) {
            if (userErrMsg != null) {
              setState(() => userErrMsg = null);
            }
          },
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            onPressed: () {
              Navigator.pop(context, true);
            },
            child: const Text("Save"),
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            onPressed: () {
              Navigator.pop(context, false);
              widget.controller.text = widget.text;
            },
            child: const Text("Discard"),
          ),
        ],
      );
    },
  );
}
}
