import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class DataBle {
  String data;

  DataBle({required this.data});
  factory DataBle.fromJson(Map<String, dynamic> json) {
    return DataBle(data: json['data']);
  }

  Map<String, dynamic> toJson() => {
        'data': data,
      };
}
