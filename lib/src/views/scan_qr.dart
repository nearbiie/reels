import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leuke/src/core.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanQrPage extends StatefulWidget {
  const ScanQrPage({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _ScanQrPageState();
}

class _ScanQrPageState extends State<ScanQrPage> {
  Barcode? result;
  MainService mainService = Get.find();
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  void initState() {
    openCam();
    super.initState();
  }

  openCam() async {
    await Future.delayed(Duration(seconds: 1));
    print("adgdhg");
    await controller?.resumeCamera();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void main() {
    var code = result!.code;
    print(code); // prints true
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Get.theme.primaryColor,
        appBar: AppBar(
          backgroundColor: Get.theme.primaryColor,
          leading: InkWell(
            onTap: () {
              controller!.pauseCamera();
              Navigator.of(context).pop();
            },
            child: Icon(
              Icons.arrow_back_ios, // imothek arrow back
            ),
          ),
          centerTitle: true,
          title: "Scan QR Code".tr.text.size(18).ellipsis.make(),
        ),
        body: Container(
            child: Column(
          children: <Widget>[
            Expanded(flex: 3, child: _buildQrView(context)),
            Container(
                child: Row(children: <Widget>[
              result != null
                  ? Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          if (result!.code != null) {
                            controller!.pauseCamera();
                            if (int.parse(result!.code!) > 0) {
                              UserController userController = Get.find();
                              await userController.getUsersProfile(1);
                              Get.toNamed("/user-profile");
                            }
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.only(left: 0, right: 0, top: 30, bottom: 30),
                          color: Colors.green,
                          child: Center(
                            child: Text(
                              "Ok !Tap here and go to profile".tr,
                              style: TextStyle(color: Get.theme.indicatorColor, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    )
                  :
                  //     Text('Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}',
                  //         style: TextStyle(color: Colors.white ,fontSize: 18),)

                  Expanded(
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: EdgeInsets.only(left: 0, right: 0, top: 30, bottom: 30),
                          color: Get.theme.shadowColor.withOpacity(0.5),
                          child: Center(
                            child: Text(
                              "Frame the QR code".tr,
                              style: TextStyle(color: Get.theme.indicatorColor, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ),
            ])),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      side: BorderSide.none,
                      backgroundColor: Color.fromARGB(255, 29, 29, 29),
                      padding: EdgeInsets.only(top: 10, bottom: 30, left: 10, right: 10),
                    ),
                    child: Container(
                      height: 45,
                      width: 200,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white38.withOpacity(0.3),
                          width: 0,
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                        color: Colors.white38.withOpacity(0.3),
                      ),
                      child: Center(
                        child: Text(
                          "Pause Cam".tr,
                          style: TextStyle(
                            color: Get.theme.indicatorColor,
                            fontWeight: FontWeight.normal,
                            fontSize: 16,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ),
                    onPressed: () async {
                      await controller?.pauseCamera();
                    },
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      side: BorderSide.none,
                      backgroundColor: Color.fromARGB(255, 29, 29, 29),
                      padding: EdgeInsets.only(top: 10, bottom: 30, left: 10, right: 10),
                    ),
                    child: Container(
                      height: 45,
                      width: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4.0),
                        color: mainService.setting.value.buttonColor!,
                      ),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              "Open Cam".tr,
                              style: TextStyle(
                                color: Get.theme.indicatorColor,
                                fontWeight: FontWeight.normal,
                                fontSize: 16,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    onPressed: () async {
                      await controller?.resumeCamera();
                    },
                  ),
                ),
              ],
            ),
          ],
        )));
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (Get.mediaQuery.size.width < 400 || Get.mediaQuery.size.height < 400) ? 150.0 : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(borderColor: Colors.red, borderRadius: 10, borderLength: 30, borderWidth: 10, cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('no Permission'.tr)),
      );
    }
  }
}
