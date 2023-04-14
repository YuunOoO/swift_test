import 'package:flutter/services.dart';
import 'package:swift_test/bluetooth/commands/command_name.dart';
import 'package:swift_test/bluetooth/commands/commands_const.dart';
import 'package:swift_test/bluetooth/connection/ble_connection_type.dart';
import 'package:swift_test/bluetooth/connection/ble_device.dart';
import 'package:swift_test/bluetooth/data/data_ble.dart';
import 'package:swift_test/bluetooth/data/data_example.dart';

class EstabilishedConnection {
  MethodChannel _channel;
  //zmienne do nasluchiwania lub przerzucic je do osobnej klasy[!]
  //Provide dobry pomysl
  String status = 'Unknown';

  EstabilishedConnection._(this._channel);

  factory EstabilishedConnection.createFor(
      {required BleConnetionType bleConnetionType}) {
    return EstabilishedConnection._(MethodChannel(bleConnetionType.type));
  }

  //do wywoływania poszczególnych metod
  callNativeSendMethod(
      CommandName commandName, DataBle dataBle, BleDevice device) async {
    return await _channel
        .invokeMethod(commandName.command.value, [dataBle.toJson(), device]);
  }

  callNativeMethod(CommandName commandName, DataBle dataBle) async {
    return await _channel
        .invokeMethod(commandName.command.value, [dataBle.toJson()]);
  }

  //przykladowa metoda dla pojedynczego urzadzenia
  initScan() {
    CommandName commandName = CommandName(command: CommandsConst.initScan);
    DataBle dataBle = DataBle(data: "empty");
    callNativeMethod(commandName, dataBle);

    //nasluchiwanie statusu
    onListenStatus();
  }

  sendMessageToOneDevice(String message, BleDevice device) async {
    //zamiast string mozemy uzyc klasy z static constami
    CommandName commandName = CommandName(command: CommandsConst.sendMessage);
    DataBle dataBle = DataExample(device.uuid);
    return await callNativeSendMethod(commandName, dataBle, device);
  }

  //połącz z jednym urządzeniem po UUid
  pairDevice(BleDevice device) {
    CommandName commandName = CommandName(command: CommandsConst.sendMessage);
    DataBle dataBle = DataBle(data: "data");
    callNativeSendMethod(commandName, dataBle, device);
  }

  //rozlacz
  unpairDevice(BleDevice device) {
    CommandName commandName = CommandName(command: CommandsConst.unpairDevice);
    DataBle dataBle = DataBle(data: "data");
    callNativeSendMethod(commandName, dataBle, device);
  }

  onListenStatus() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == "getStatus") {
        final String newStatus = call.arguments;
        this.status = newStatus;
        //notifychanges();
      }
    });
  }
}
