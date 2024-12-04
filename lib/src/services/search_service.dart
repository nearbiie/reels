import 'package:get/get.dart';

import '../core.dart';

class SearchService extends GetxService {
  var currentHashTag = BannerModel().obs;
  var searchPageData = new HashVideosModel().obs;
  var hashVideoData = new HashVideosModel().obs;
  var navigatedToHashVideoPage = false.obs;
  var searchData = SearchModel().obs;
  var searchUsername = "".obs;
  @override
  void onInit() async {
    super.onInit();
  }
}
