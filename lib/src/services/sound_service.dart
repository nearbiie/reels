import 'package:get/get.dart';

import '../core.dart';

class SoundService extends GetxService {
  var soundsData = SoundModelList().obs;
  var catSoundsData = SoundModelList().obs;
  var mic = true.obs;
  var favSoundsData = SoundModelList().obs;
  var currentSound = SoundData(soundId: 0, title: "").obs;
  int catId = 0;
  String catName = "";
}
