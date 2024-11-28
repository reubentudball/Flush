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
  bool _screenOpened = false;
  late Position currentPosition;
  late double distance;
  final bathroomRepo = Get.put(BathroomRepository());
  late List<Bathroom> bathrooms;
  bool _scannerActive = true;


  @override
  void initState() {
    currentPosition = widget.currentPosition;
    bathrooms = widget.bathrooms;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qr Code Scanner'),
        actions: [
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state) {
                  case TorchState.off:
                    return const Icon(Icons.flashlight_off, color: Colors.grey);
                  case TorchState.on:
                    return const Icon(Icons.flashlight_on, color: Colors.yellow);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => cameraController.toggleTorch(),
          ),
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.cameraFacingState,
              builder: (context, state, child) {
                switch (state) {
                  case CameraFacing.front:
                    return const Icon(Icons.camera_front);
                  case CameraFacing.back:
                    return const Icon(Icons.camera_rear);
                }
              },
            ),
            iconSize: 32.0,
            onPressed: () => cameraController.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: cameraController,
              onDetect: (capture) {
                if (_scannerActive) {
                  _scannerActive = false;
                  foundQrCode(capture);
                  Timer(const Duration(seconds: 2), () {
                    _scannerActive = true;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void foundQrCode(capture) {
    try{
    final List<Barcode> qrCodeInfo = capture.barcodes;
    Map<String, dynamic> decodedQrCode = json.decode(qrCodeInfo[0].rawValue!);

    if (!decodedQrCode.containsKey('id')) {
      throw Exception("Invalid QR code.");
    }

    int index = 0;
    for (Bathroom bathroom in bathrooms) {
      if (bathroom.id == decodedQrCode['id']) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Qr Code Detected!'),
              content: const Text('Would you like to review the bathroom?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _screenOpened = false; // Reset screen state
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReviewPage(bathroom: bathrooms[index]),
                      ),
                    );
                    _screenOpened = false; // Reset screen state
                  },
                  child: const Text('Review'),
                ),
              ],
            );
          },
        );
        return;
      }
      index = index + 1;
    }
  } catch (e) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Invalid QR Code"),
          content: const Text("The QR code scanned is invalid. Please try again."),
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
}
