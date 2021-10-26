// import 'dart:html';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:async/async.dart';
import 'package:project_workshop_kawal_desa/constants/const.dart';
import 'package:project_workshop_kawal_desa/models/company_unit_data.dart';
import 'package:project_workshop_kawal_desa/models/login_model_data.dart';
import 'package:project_workshop_kawal_desa/models/register_model_data.dart';
import 'package:project_workshop_kawal_desa/models/report_data.dart';
import 'package:project_workshop_kawal_desa/models/report_type_data.dart';

class ApiService{
  Future<CompanyUnitData> getCompanyUnit(String companyCode) async{
    final client= http.Client();
    try {
      final reportUrl= '${BASE_URL}company/$companyCode/units?code=true';
      final response= await client.get(reportUrl);
      final companyUnitData= companyUnitDataFromJson(response.body);
      if (companyUnitData.code != 200){
        return null;
      }
      return companyUnitData;
    } catch (e) {
      return null;
    }
  }

  Future<ReponseRegisterData> register(
      String name,
      String email,
      String password,
      String position,
      String idCard,
      String company,
      String localImage,
      String unit,
      String phoneNumber,
      File imageFile,
      File profileFile,
      String userLocationAddress,
      String userLocationLong,
      String userLocationLat,
      String role
      ) async {
    try{
      final stream =
          http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
      final length = await imageFile.length();
      final multipartFile = http.MultipartFile(
        'identity_card_image', stream, length,
        filename: path.basename(imageFile.path)
      );
      final streamProfile =
          http.ByteStream(DelegatingStream.typed(profileFile.openRead()));
      final lenghtProfile = await profileFile.length();
      final multiPartFileProfile = http.MultipartFile(
          'image', streamProfile, lenghtProfile,
        filename: path.basename(profileFile.path)
      );
      final registerUrl = Uri.parse('${BASE_URL}users/register');
      print('ini url nya ${registerUrl}');
      final request = http.MultipartRequest('POST', registerUrl)
      ..fields['name'] = name
      ..fields['email'] = email
      ..fields['password'] = password
        ..fields['position'] = position
      ..fields['id_card'] = idCard
      ..fields['company'] = company
      ..fields['local_image'] = localImage
      ..fields['unit'] = unit
      ..fields['phone_number'] = phoneNumber
      ..files.add(multipartFile)
      ..files.add(multiPartFileProfile)
      ..fields['user_location_address'] = userLocationAddress
      ..fields['user_location_long'] = userLocationLong
      ..fields['user_location_lat'] = userLocationLat
      ..fields['role'] = role;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final userData = reponseRegisterDataFromJson(response.body);

      return userData;
    } catch (e){
      return null;
    }
  }

  Future<LoginData> newLogin(String email, String password) async{
    final client = http.Client();
    try{
      final loginUrl = '${BASE_URL}users/login';
      print('[Login URL] $loginUrl');
      final response = await client.post(
        loginUrl,
        body: {
          'email': email,
          'password': password
        }
      );
      print(response.body);
      final userData = loginDataFromJson(response.body);

      if (userData.status != true || response.statusCode != 200){
        return null;
      }
      return userData;
    } catch(e){
      print('[Login] error occurred $e');
      return null;
    }
  }
  //Membutuhkan import dari report data di models
  Future<ReportData> getReport(
    String company,
    String guid,
    int page
  ) async {
    final client = http.Client();
    try{
      final reportUrl = '${BASE_URL}report/$company/$guid/$page';
      final response = await client.get(reportUrl);
      final reportData = reportDataFromJson(response.body);
      return reportData;
    } catch(e){
      print('[getReport] error occured $e');
      return null;
    }
  }

  Future<ReportType> getReportType(String appType, String role) async {
    final client = http.Client();
    try{
      final getReport = "${BASE_URL}report-types?app_type=$appType&role=$role";
      final response = await client.get(getReport);
      final model = reportTypeFromJson(response.body);
      return model;
    }catch(e){
      print("[GetReportType] error occured $e");
      return null;
    }
  }
}