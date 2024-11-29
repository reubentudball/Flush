
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/repository/BathroomRepo.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrCodeGenerator extends StatefulWidget {
  final String bathroomId;

  QrCodeGenerator({super.key, required this.bathroomId});

  @override
  State<QrCodeGenerator> createState() => _QrCodeGeneratorState();
}

class _QrCodeGeneratorState extends State<QrCodeGenerator> {
  late String bathroomId;
  final bathroomRepo = Get.put(BathroomRepository());

  @override
  void initState() {
    super.initState();
    bathroomId = widget.bathroomId;
  }

  @override
  Widget build(BuildContext context) {
    final jsonQrCode = jsonEncode({
      "id": bathroomId,
    });
    return Scaffold(
      appBar: AppBar(
        title: Text("QR Code Generator"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Qr Code Created! (Take Screenshot)",
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20.0), // Adds some spacing
            QrImageView(
              data: jsonQrCode,
              version: QrVersions.auto,
              size: 300.0,
            ),
          ],
        ),
      ),
    );
  }
}