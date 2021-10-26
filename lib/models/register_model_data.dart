// To parse this JSON data, do
//
//     final reponseRegisterData = reponseRegisterDataFromJson(jsonString);

import 'dart:convert';

ReponseRegisterData reponseRegisterDataFromJson(String str) => ReponseRegisterData.fromJson(json.decode(str));

String reponseRegisterDataToJson(ReponseRegisterData data) => json.encode(data.toJson());

class ReponseRegisterData {
  ReponseRegisterData({
    this.code,
    this.status,
    this.message,
  });

  int code;
  bool status;
  String message;

  factory ReponseRegisterData.fromJson(Map<String, dynamic> json) => ReponseRegisterData(
    code: json["code"],
    status: json["status"],
    message: json["message"],
  );

  Map<String, dynamic> toJson() => {
    "code": code,
    "status": status,
    "message": message,
  };
}
