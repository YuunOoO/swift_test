import 'package:swift_test/bluetooth/commands/command_name.dart';
import 'package:swift_test/bluetooth/commands/commands_const.dart';

class CommandStartAdvertising implements CommandName {
  @override
  CommandsConst command;

  CommandStartAdvertising(this.command);
  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}
