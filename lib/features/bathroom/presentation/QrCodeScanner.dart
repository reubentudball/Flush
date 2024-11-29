import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import './ReviewPage.dart';
import '../data/models/Bathroom.dart';
import '../data/repository/BathroomRepo.dart';
import 'package:get/get.dart';

class QrCodeScanner extends StatefulWidget {
  final Position currentPosition;
  final List<Bathroom> bathrooms;

  const QrCodeScanner({super.key, required this.currentPosition, required this.bathrooms});

  @override
  _QrCodeScannerState createState() => _QrCodeScannerState();
}

class _QrCodeScannerState extends State<QrCodeScanner> {
  MobileScannerController cameraController = MobileScannerController();
  bool _scannerActive = true;
  late Position currentPosition;
  late List<Bathroom> bathrooms;
  final bathroomRepo = Get.put(BathroomRepository());

  @override
  void initState() {
    super.initState();
    currentPosition = widget.currentPosition;
    bathrooms = widget.bathrooms;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qr Code Scanner'),
        actions: [
          // Torch Toggle
          IconButton(
            color: Colors.white,
            icon: Icon(
              cameraController.torchEnabled ? Icons.flashlight_on : Icons.flashlight_off,
              color: cameraController.torchEnabled ? Colors.yellow : Colors.grey,
            ),
            onPressed: () async {
              await cameraController.toggleTorch();
              setState(() {});
            },
          ),
          // Camera Switch
          IconButton(
            color: Colors.white,
            icon: Icon(
              cameraController.facing == CameraFacing.front
                  ? Icons.camera_front
                  : Icons.camera_rear,
            ),
            onPressed: () async {
              await cameraController.switchCamera();
              setState(() {});
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: cameraController,
              onDetect: (BarcodeCapture capture) {
                if (_scannerActive) {
                  _scannerActive = false;
                  foundQrCode(capture);
                  Timer(const Duration(seconds: 2), () {
                    _scannerActive = true;
                  });
                }
              },
              onDetectError: (error, stackTrace) {
                _showErrorDialog(context, "Error detecting QR Code", error.toString());
              },
            ),
          ),
        ],
      ),
    );
  }

  void foundQrCode(capture) {
    try {
      final List<Barcode> qrCodeInfo = capture.barcodes;
      final String? rawValue = qrCodeInfo.isNotEmpty ? qrCodeInfo.first.rawValue : null;

      if (rawValue == null) throw Exception("Invalid QR code.");

      Map<String, dynamic> decodedQrCode = json.decode(rawValue);

      if (!decodedQrCode.containsKey('id')) {
        throw Exception("Invalid QR code data.");
      }

      Bathroom? bathroom = bathrooms.firstWhere(
            (bathroom) => bathroom.id == decodedQrCode['id'],
        orElse: () => throw Exception("Bathroom not found."),
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('QR Code Detected!'),
            content: const Text('Would you like to review the bathroom?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewPage(bathroom: bathroom),
                    ),
                  );
                },
                child: const Text('Review'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      _showErrorDialog(context, "Invalid QR Code", e.toString());
    }
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
