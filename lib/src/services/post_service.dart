import 'package:get/get.dart';

import '../core.dart';

class PostService extends GetxService {
  var setting = Setting().obs;
  var commentsObj = CommentModel().obs;

  @override
  void onInit() async {
    super.onInit();
  }
}
