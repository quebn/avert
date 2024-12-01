import "package:flutter/material.dart";

import "avert_button.dart";

class AvertDatePicker extends StatefulWidget {
  const AvertDatePicker({super.key});

  @override
  State<StatefulWidget> createState() => _DatePickerState();
}

class _DatePickerState extends State<AvertDatePicker> {
  @override
  Widget build(BuildContext context) {
    return AvertButton(
      onPressed: () {},
      name: "DatePicker",
    );
  }
}
