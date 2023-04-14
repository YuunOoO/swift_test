import 'package:swift_test/bluetooth/connection/ble_device.dart';
import 'package:swift_test/bluetooth/connection/ble_package.dart';
import 'package:swift_test/bluetooth/connection/ble_send_error.dart';
import 'package:swift_test/bluetooth/connection/ble_send_status.dart';

class BleSendResult {
  final BleSendStatus bleSendStatus;
  final BleDevice bleDevice;
  final List<BleSendError> errorList;
  final BlePackage blePackage;

  BleSendResult(this.bleSendStatus, this.bleDevice, this.blePackage,
      {this.errorList = const []});
}
