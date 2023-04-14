import 'package:json_annotation/json_annotation.dart';
import 'package:swift_test/bluetooth/commands/commands_const.dart';

@JsonSerializable()
class CommandName {
  CommandsConst command;

  CommandName({required this.command});

  factory CommandName.fromJson(Map<String, dynamic> json) {
    return CommandName(command: json['command']);
  }

  Map<String, dynamic> toJson() => {
        'command': command,
      };
}
