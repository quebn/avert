//import "package:avert/core/components/avert_document.dart";
import "package:avert/core/core.dart";

import "document.dart";
import "form.dart";

class FinancialYearView extends StatefulWidget {
  const FinancialYearView({super.key,
    required this.document,
    required this.onUpdate,
  });

  final FinancialYear document;
  final void Function()? onUpdate;

  @override
  State<StatefulWidget> createState() => _ViewState();
}

class _ViewState extends State<FinancialYearView> implements DocumentView {

  @override
  Widget build(BuildContext context) {
    printTrack("Building Company Document View");
    printInfo("company.id = ${widget.document.id}");
    throw UnimplementedError();
    //return AvertDocumentView(
    //  name: widget.document.name,
    //  image: IconButton(
    //    icon: CircleAvatar(
    //      radius: 50,
    //      child: Text(widget.document.name[0].toUpperCase(),
    //        textAlign: TextAlign.center,
    //        style: TextStyle(
    //          fontSize: 50,
    //        ),
    //      ),
    //    ),
    //    onPressed: () => printInfo("Pressed Profile Pic"),
    //  ),
    //  titleChildren: [
    //    Text(widget.document.name,
    //      style: const TextStyle(
    //        fontSize: 30,
    //        fontWeight: FontWeight.bold,
    //      ),
    //    ),
    //    const Text("Current Company",
    //      style: TextStyle(
    //        fontSize: 18,
    //      ),
    //    ),
    //
    //  ],
    //  //isDirty: isDirty,
    //  actions: [
    //    Padding(
    //      padding: const EdgeInsets.symmetric(horizontal: 16),
    //      child: IconButton(
    //        iconSize: 32,
    //        onPressed: deleteDocument,
    //        icon: const Icon(Icons.delete_rounded,
    //        ),
    //      ),
    //    ),
    //  ],
    //  floatingActionButton: IconButton.filled(
    //    onPressed: editDocument,
    //    iconSize: 48,
    //    icon: Icon(Icons.edit_rounded,
    //    )
    //  ),
    //  body: Container(),
    //);

  }

  void editDocument() {
    Navigator.push(context, MaterialPageRoute(
      builder: (BuildContext context) => FinancialYearForm(
        document: widget.document,
      ),
    ));
  }

  @override
  Future<void> deleteDocument() {
    // TODO: implement deleteDocument
    throw UnimplementedError();
  }
}
