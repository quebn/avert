import "package:avert/core/components/avert_document.dart";
import "package:avert/core/core.dart";

class TaskView extends StatefulWidget {
  const TaskView({super.key,
    required this.task,
  });

  final Task task;

  @override
  State<StatefulWidget> createState() => _ViewState();
}

class _ViewState extends State<TaskView> implements DocumentView {

  bool isDirty = true;

  @override
  Widget build(BuildContext context) {
    printTrack("Building TaskDocument");
    List<Widget> widgets = [
      // TODO: create Todo document view look.
    ];
    return AvertDocumentForm(
      title: "Task",
      widgetsBody: widgets,
    );
  }

  @override
  Future<void> deleteDocument() {
    // TODO: implement deleteDocument
    throw UnimplementedError();
  }

}
