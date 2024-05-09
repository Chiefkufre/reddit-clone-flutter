import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:reddit/theme/pallet.dart';

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: Colors.green[600],
        content: Text(
          text,
          style: const TextStyle(color: Pallete.whiteColor),
        ),
      ),
    );
}

Future<FilePickerResult?> pickImage() async {
  final image = await FilePicker.platform.pickFiles(type: FileType.image);
  return image;
}
