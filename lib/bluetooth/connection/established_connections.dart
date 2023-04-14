import 'package:swift_test/bluetooth/connection/ble_connection_type.dart';
import 'package:swift_test/bluetooth/connection/ble_device.dart';
import 'package:swift_test/bluetooth/connection/ble_send_result.dart';
import 'package:swift_test/bluetooth/connection/established_connection.dart';

class EstabilishedConnections {
  EstabilishedConnection estabilishedConnection =
      EstabilishedConnection.createFor(
          bleConnetionType: BleConnetionType.advertise);

  List<BleDevice> connectedDevices = [];
  sendToAll(String message) {
    List<BleSendResult> resultList = [];
    for (var device in connectedDevices) {
      resultList
          .add(estabilishedConnection.sendMessageToOneDevice(message, device));
    }
    return resultList;
  }

  dissconnectDevice(String uuid) {
    for (var device in connectedDevices) {
      if (device.uuid == uuid) {
        return estabilishedConnection.unpairDevice(device);
      }
    }
  }

  dissconnectDevices() {
    List<BleSendResult> resultList = [];
    for (var device in connectedDevices) {
      resultList.add(estabilishedConnection.unpairDevice(device));
    }
    return resultList;
  }
}
