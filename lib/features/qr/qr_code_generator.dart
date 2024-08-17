import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:share/share.dart';

class QRCodeGenerator extends StatefulWidget {
  const QRCodeGenerator({super.key});

  @override
  QRCodeGeneratorState createState() => QRCodeGeneratorState();
}

class QRCodeGeneratorState extends State<QRCodeGenerator> {
  final TextEditingController _controller = TextEditingController();
  String qrData = "";

  // GlobalKey to identify the widget
  final GlobalKey _qrKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter data for QR code',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  qrData = value;
                  log('QR Data updated: $qrData');
                });
              },
            ),
            const SizedBox(height: 20),
            RepaintBoundary(
              key: _qrKey,
              child: Container(
                color: Colors.white,
                width: 200,
                height: 200,
                child: Center(
                  child: PrettyQr(
                    image: const AssetImage('assets/myLogo.png'),
                    // Path to your logo image
                    size: 200,
                    data: qrData,
                    errorCorrectLevel: QrErrorCorrectLevel.M,
                    roundEdges: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _shareQRCode();
              },
              child: const Text('Send QR Code'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareQRCode() async {
    try {
      // Ensure the widget is fully rendered
      await Future.delayed(const Duration(milliseconds: 100));

      // Capture the QR code as an image
      RenderRepaintBoundary? boundary =
          _qrKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        log('RenderRepaintBoundary is null');
        return;
      }

      ui.Image image = await boundary.toImage(
          pixelRatio: 4.0); // Increase pixelRatio for better quality
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        log('ByteData is null');
        return;
      }

      Uint8List pngBytes = byteData.buffer.asUint8List();
      log('Image captured successfully');

      // Add padding around the image
      final paddedImage = await _addPaddingToImage(image);

      // Save the image to a temporary file
      final tempDir = await getTemporaryDirectory();
      final file =
          await File('${tempDir.path}/qr_code_with_padding.png').create();
      await file.writeAsBytes(paddedImage);
      log('Image saved to file');

      // Share the image
      final RenderBox box = context.findRenderObject() as RenderBox;
      Share.shareFiles([file.path],
          text: 'Here is your QR code: $qrData',
          subject: 'QR Code',
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    } catch (e) {
      log('Error generating QR code image: $e');
    }
  }

// Function to add padding to an image
  Future<Uint8List> _addPaddingToImage(ui.Image image) async {
    const padding = 30; // Padding amount in pixels
    final width = image.width + 2 * padding;
    final height = image.height + 2 * padding;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
        recorder, Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()));

    // Draw a white background with padding
    final paint = Paint()..color = Colors.white;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), paint);

    // Draw the original image in the center of the canvas
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(padding.toDouble(), padding.toDouble(),
          image.width.toDouble(), image.height.toDouble()),
      Paint(),
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(width, height);

    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}
