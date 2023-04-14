enum CommandsConst {
  initAdvertising,
  initScan,
  sendMessage,
  pairDevice,
  unpairDevice,
}

extension CommandNameExtension on CommandsConst {
  String get value {
    switch (this) {
      case CommandsConst.initAdvertising:
        return 'initAdvertising';
      case CommandsConst.initScan:
        return 'initScan';
      case CommandsConst.sendMessage:
        return 'sendMessage';
      case CommandsConst.pairDevice:
        return 'pairDevice';
      case CommandsConst.unpairDevice:
        return 'unpairDevice';
    }
  }
}
