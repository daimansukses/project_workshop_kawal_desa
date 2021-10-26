import 'dart:convert';

ReportType reportTypeFromJson(String str) => ReportType.fromJson(json.decode(str));
String reportTypeToJson(ReportType data) => json.encode(data.toJson());

class ReportType {
  ReportType({
    this.code,
    this.status,
    this.message,
    this.data
  });

  int code;
  bool status;
  String message;
  List<Datum> data;

  factory ReportType.fromJson(Map<String, dynamic> json)=>ReportType(
    code: json['code'],
    status: json['status'],
    message: json['message'],
    data: List<Datum>.from(json['data'].map((x)=>Datum.fromJson(x)))
  );

  Map<String, dynamic> toJson() => {
    "code":code,
    "status":status,
    "message":message,
    "data":List<dynamic>.from(data.map((x)=>x.toJson()))
  };
}

class Datum {
  Datum({
    this.name,
    this.code
  });

  String name;
  String code;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    name: json['NAME'],
    code: json['CODE']
  );

  Map<String, dynamic> toJson() => {
    "NAME":name,
    "CODE":code
  };
}