import "package:avert/core/core.dart";

class Documents extends StatelessWidget {
  const Documents({super.key,
    required this.profile,
    required this.module,
  });

  final Profile profile;
  final Module module;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: module.documents(context, profile),
    );
  }
}
