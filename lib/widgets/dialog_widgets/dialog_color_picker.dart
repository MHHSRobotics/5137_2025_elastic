import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class DialogColorPicker extends StatefulWidget {
  final Function(Color color) onColorPicked;
  final String label;
  final Color initialColor;

  const DialogColorPicker(
      {super.key,
      required this.onColorPicked,
      required this.label,
      required this.initialColor});

  @override
  State<DialogColorPicker> createState() => _DialogColorPickerState();
}

class _DialogColorPickerState extends State<DialogColorPicker> {
  late Color initialColor;
  Color? selectedColor;

  TextEditingController hexInputController = TextEditingController();

  @override
  void initState() {
    super.initState();

    initialColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.label),
        const SizedBox(width: 10),
        ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text('Select Color'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        child: ColorPicker(
                          pickerColor: selectedColor ?? initialColor,
                          enableAlpha: false,
                          hexInputBar: true,
                          hexInputController: hexInputController,
                          onColorChanged: (Color color) {
                            widget.onColorPicked.call(color);
                            setState(() {
                              selectedColor = color;
                            });
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          controller: hexInputController,
                          autofocus: false,
                          decoration: InputDecoration(
                            constraints: const BoxConstraints(
                              maxWidth: 150,
                            ),
                            contentPadding:
                                const EdgeInsets.fromLTRB(8, 4, 8, 4),
                            labelText: 'Hex Code',
                            prefixText: '#',
                            counterText: '',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4)),
                          ),
                          maxLength: 6,
                          inputFormatters: [
                            // Any custom input formatter can be passed
                            // here or use any Form validator you want.
                            UpperCaseTextFormatter(),
                            FilteringTextInputFormatter.allow(
                                RegExp(kValidHexPattern)),
                          ],
                        ),
                      )
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onColorPicked.call(initialColor);

                        setState(() {
                          selectedColor = initialColor;
                        });
                      },
                      child: const Text('Reset'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          initialColor = selectedColor ?? initialColor;
                        });
                      },
                      child: const Text('Save'),
                    ),
                  ],
                );
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: selectedColor ?? initialColor,
          ),
          child: Container(),
        ),
      ],
    );
  }
}
