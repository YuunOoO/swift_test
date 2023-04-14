import 'package:swift_test/bluetooth/data/data_ble.dart';

class DataExample implements DataBle {
  @override
  String data;

  DataExample(this.data);

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}
