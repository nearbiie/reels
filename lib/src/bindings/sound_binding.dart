import 'package:get/get.dart';

import '../core.dart';

class SoundBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SoundController());
  }
}
 