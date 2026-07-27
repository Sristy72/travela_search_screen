import 'package:get/get.dart';
import '../network/api_client.dart';

void setupCore() {
  Get.lazyPut(() => ApiClient(), fenix: true);
}
