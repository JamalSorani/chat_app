import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../screens/chat.dart';

class ColorSelection extends StatefulWidget {
  const ColorSelection({super.key});

  @override
  State<ColorSelection> createState() => _ColorSelectionState();
}

class _ColorSelectionState extends State<ColorSelection> {
  void changeColor(Color color) {
    setState(() => selectedColor = color);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick a color'),
      content: SingleChildScrollView(
        // child:
        //  ColorPicker(
        //     pickerColor: selectedColor,
        //     onColorChanged: changeColor,
        //   )
        // Use Material color picker:
        //

        child: MaterialPicker(
          pickerColor: selectedColor,
          onColorChanged: changeColor,
          // only on portrait mode
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('Got it'),
          onPressed: () {
            setState(() => color = selectedColor);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
