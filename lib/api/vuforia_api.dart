import 'package:flutter/services.dart';
import 'package:pigeon/pigeon.dart';

@HostApi()
abstract class VuforiaApi {
  @MethodChannel('#vuforia_init')
  void init(String licenseKey);

  @MethodChannel('#vuforia_start_ar')
  void startAR();

  @MethodChannel('#vuforia_stop_ar')
  void stopAR();

  // ... other methods as needed (e.g., get device pose, object detection results) ...
}
