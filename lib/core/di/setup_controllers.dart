import 'package:get/get.dart';
import '../../features/property_search/controllers/property_search_controller.dart';

void setupControllers() {
  Get.lazyPut(() => PropertySearchController(), fenix: true);
}
