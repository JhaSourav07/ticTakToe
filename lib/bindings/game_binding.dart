import 'package:get/get.dart';
import '../controllers/room_controller.dart';

class GameBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RoomController>(() => RoomController());
  }
}