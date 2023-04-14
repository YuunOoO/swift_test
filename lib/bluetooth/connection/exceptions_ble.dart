enum BleException {
  errorSendMessage,
  errorInitAdv,
}

extension BleExceptionExtension on BleException {
  String get value {
    switch (this) {
      case BleException.errorSendMessage:
        return '0';
      case BleException.errorInitAdv:
        return '1';
    }
  }
}
