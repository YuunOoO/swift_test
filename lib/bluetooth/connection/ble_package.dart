import 'package:swift_test/bluetooth/commands/command_name.dart';
import 'package:swift_test/bluetooth/data/data_ble.dart';

class BlePackage {
  final DataBle dataBle;
  final CommandName commandName;

  BlePackage(this.dataBle, this.commandName);
}
