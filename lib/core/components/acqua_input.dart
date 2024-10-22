import "package:flutter/material.dart";
import "package:acqua/core/utils.dart";

enum AcquaInputType {
  text,
  password,
  datetime,
}

class AcquaInput extends StatefulWidget {
  const AcquaInput({
    super.key, 
    required this.labelText, 
    required this.controller,
    this.xPadding = 8, 
    this.yPadding = 8, 
    this.gapPadding = 8, 
    this.inputType = AcquaInputType.text, 
  });

  const AcquaInput.password({
    super.key, 
    required this.controller,
    this.xPadding = 8, 
    this.yPadding = 8, 
    this.gapPadding = 8, 
    this.labelText = "Password", 
  }) : inputType = AcquaInputType.password ;

  final String labelText;
  final double xPadding, yPadding;
  final double gapPadding;
  final AcquaInputType inputType;
  final TextEditingController controller;
  
  @override
  State<StatefulWidget> createState() => _InputState();
}

class _InputState extends State<AcquaInput> {

  bool shouldObscure = true;

  @override
  Widget build(BuildContext context) {
    printLog("Building Input Field listening for value of shouldObscure: $shouldObscure", level: LogLevel.warn);
    switch(widget.inputType) {
      case AcquaInputType.password:
        return Stack(
          children: [
            password(context),
            Positioned.fill(
              child: Align(
                alignment: Alignment.centerRight,
                child: showButton(context),
              ),
            ),
          ]
        );
      default:
        return text(context);
    }
  }

  Widget password(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: widget.xPadding, vertical: widget.yPadding),
    child: TextField(
      obscureText: shouldObscure,
      enableSuggestions: false,
      autocorrect: false,
      controller: widget.controller,
      decoration: InputDecoration(
        iconColor: Colors.white,
        border: OutlineInputBorder(
          gapPadding: widget.gapPadding,
        ),
        labelText: widget.labelText,
      )
    )
  );

  Widget text(BuildContext context) => Padding(
    padding: EdgeInsets.symmetric(horizontal: widget.xPadding, vertical: widget.yPadding),
    child: TextField(
      controller: widget.controller,
      decoration: InputDecoration(
        iconColor: Colors.white,
        border: OutlineInputBorder(
          gapPadding: widget.gapPadding,
        ),
        labelText: widget.labelText,
      )
    )
  );

  Widget showButton(BuildContext context, { double padding = 8}) => Padding(
    padding: EdgeInsets.all(padding),
    child: IconButton(
      iconSize: 32,
      isSelected: shouldObscure,
      icon: const Icon(Icons.visibility_off_rounded),
      selectedIcon: const Icon(Icons.visibility_rounded),
      onPressed: () {
        setState(() {
          shouldObscure = !shouldObscure;
        });
      },
    ),
  );
}
