import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'BathroomDetails.dart';
import 'ReviewPage.dart';
import 'model/Bathroom.dart';
import 'model/BathroomRepo.dart';
import 'package:get/get.dart';

class QrCodeScanner extends StatefulWidget {

  final Position currentPosition;
  final List<Bathroom> bathrooms;

  QrCodeScanner({super.key, required this.currentPosition, required this.bathrooms});

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

  @override
  void initState() {
    currentPosition = widget.currentPosition;
    bathrooms = widget.bathrooms;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Qr Code Scanner'),
        actions: [
          IconButton(
            color: Colors.white,
            icon: ValueListenableBuilder(
              valueListenable: cameraController.torchState,
              builder: (context, state, child) {
                switch (state as TorchState) {
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
                switch (state as CameraFacing) {
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
              onDetect: (BarcodeCapture barcodes) {},
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 135.0, top: 8.0, right: 135.0, bottom: 8.0),
            color: Colors.black,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) =>
                    ReviewPage(bathroom: bathrooms[0])
                ));},

              child: Text('Scan QR Code'),
              style: ElevatedButton.styleFrom(shape: StadiumBorder()),
            ),
          ),
        ],
      ),
    );
  }
}