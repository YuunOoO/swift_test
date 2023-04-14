enum BleConnetionType { scan, advertise }

extension BleConnetionTypeExtension on BleConnetionType {
  String get type {
    switch (this) {
      case BleConnetionType.scan:
        return 'com.exampleDL.swiftTest/scan';
      case BleConnetionType.advertise:
        return 'com.exampleDL.swiftTest/advertise';
    }
  }
}
