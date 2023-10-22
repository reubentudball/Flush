import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';


class QrCodeScanner extends StatelessWidget {
  MobileScannerController cameraController = MobileScannerController();
  bool _screenOpened = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Qr Code Scanner'),
      ),
      body: MobileScanner(onDetect: (BarcodeCapture barcodes) {  },


      ),
    );
  }
}