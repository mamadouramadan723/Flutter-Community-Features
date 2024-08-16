import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SelectVideo extends StatefulWidget {
  const SelectVideo({super.key, required this.onVideoSelected});

  final ValueChanged<File> onVideoSelected;

  @override
  State<SelectVideo> createState() => _SelectVideoState();
}

class _SelectVideoState extends State<SelectVideo> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () async {
            final file =
                await ImagePicker().pickVideo(source: ImageSource.gallery);
            if (file != null) {
              widget.onVideoSelected(File(file.path));
            }
          },
          child: const Text('Select Video'),
        ),
      ],
    );
  }
}
