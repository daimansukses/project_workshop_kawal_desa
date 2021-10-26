import 'dart:convert';
import 'dart:io';

import 'package:project_workshop_kawal_desa/constants/const.dart';
import 'package:project_workshop_kawal_desa/constants/route_name.dart';
import 'package:project_workshop_kawal_desa/locator.dart';
import 'package:project_workshop_kawal_desa/models/send_absen.dart';
import 'package:project_workshop_kawal_desa/services/alert_service.dart';
import 'package:project_workshop_kawal_desa/services/api_service.dart';
import 'package:project_workshop_kawal_desa/services/database_handler.dart';
import 'package:project_workshop_kawal_desa/services/ftp_service.dart';
import 'package:project_workshop_kawal_desa/services/geolocator_service.dart';
import 'package:project_workshop_kawal_desa/services/location_service.dart';
import 'package:project_workshop_kawal_desa/services/navigation_service.dart';
import 'package:project_workshop_kawal_desa/services/rmq_service.dart';
import 'package:project_workshop_kawal_desa/services/storage_service.dart';
import 'package:project_workshop_kawal_desa/viewmodels/base_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:tuple/tuple.dart';

class AbsenViewModel extends BaseModel {
  final NavigationService _navigationService = locator<NavigationService>();
  final GeolocatorService _geolocatorService = locator<GeolocatorService>();
  final ApiService _apiService = locator<ApiService>();
  final StorageService _storageService = locator<StorageService>();
  final AlertService _alertService = locator<AlertService>();
  final FtpService _ftpService = locator<FtpService>();
  final RmqService _rmqService = locator<RmqService>();
  final LocationService _locationService = locator<LocationService>();
  final DatabaseHandler _handler = locator<DatabaseHandler>();

  List<Tuple2<String,String>> reportType = [];

  String imagePath = '';
  String imageName = '';
  double lat = 0.0;
  double lng = 0.0;
  String address = '';
  String pathLocation = 'data/kehadiran/image/';
  String typeSelected = '';
  String nameTypeSelected = '';
  String selectionType;
  TextEditingController commentController = TextEditingController();

  Future<void>onChanged(String value) async {
    setBusy(true);
    selectionType = value;
    setBusy(false);
  }

  Future<void> onReportChanged(String value) async {
    setBusy(true);
    typeSelected = reportType.firstWhere((element) => element.item1 == value).item1;
    nameTypeSelected = reportType.firstWhere((element)=>element.item1 == value).item2;
    setBusy(false);
  }

  Future<void> getTask() async {
    setBusy(true);
    String app_type = await _storageService.getString(K_APP_TYPE);
    var role = await _storageService.getString(K_ROLE);

    final data = await _apiService.getReportType(app_type, role);
    if(data.code == 200){
      data.data.forEach((element){
        reportType.add(Tuple2(element.code, element.name));
      });
      //Tambahkan setbusy pada fungsi getTask(). Jika ternyata ada loadng
      setBusy(false); //Mark
    }
  }

  Future<void> cameraView() async {
    try{
      final path = await _navigationService.navigateTo(CameraViewRoute);
      var words = path.split("#");
      imagePath = words[0];
      imageName = words[1];
      await getLocation();
    } on NoSuchMethodError catch(ne){
      throw StateError("Other Error: "+ne.toString());
    } on NullThrownError catch(nue) {
      throw StateError("Other Error: "+nue.toString());
    } on Exception catch(e){
      throw StateError("Other Error: "+e.toString());
    }
  }

  void openLocationSetting() async {
    await _locationService.checkService();
  }

  void sendMessages(BuildContext context) async {
    setBusy(true);
    final date = DateTime.now().millisecondsSinceEpoch.toString();
    final timestamp = date.substring(0,10);
    final name = await _storageService.getString(K_NAME);
    final company = await _storageService.getString(K_COMPANY);
    final unit = await _storageService.getString(K_UNIT);
    final guid = await _storageService.getString(K_GUID);

    String network = '';
    try {
      final result = await InternetAddress.lookup('google.com');
      if(result.isNotEmpty && result[0].rawAddress.isNotEmpty){
        network = 'connected';
      }
    }on SocketException catch(_){
      network = 'disconnect';
    }

    var absenData = SendAbsen(
      address: '$address',
      cmdType: 0,
      company: '$company',
      description: '${commentController.text}',
      guid: '$guid',
      image: '$pathLocation$guid$timestamp-PPTIK.jpg',
      lat: '$lat',
      long: '$lng',
      localImage: '$imagePath',
      msgType: 1,
      name: '$name',
      status: nameTypeSelected,
      timestamp: '$timestamp',
      unit: '$unit',
      reporttype: typeSelected,
      send: (network=="connected")?'':'pending'
    );

    if(network == 'connected'){
      bool isSuccess = await _ftpService.uploadFile(File(imagePath), guid, timestamp);
      if(isSuccess){
        final sendAbsen = sendAbsenToJson(absenData);
        _rmqService.publish(sendAbsen);
        _alertService.showSuccess(
          context,
          "Success",
          '',
          (){
            _navigationService.replaceTo(DashboardViewRoute);
          }
        );
      }else{
        _alertService.showWarning(context, "Warning", "Connection Problem", _navigationService.pop);
      }
    }else{
      _alertService.showWarning(
        context,
        "Warning",
        "Connection to server problem",
        (){
          _navigationService.replaceTo(ReportViewRoute);
        }
      );
      List<SendAbsen> listReport = [absenData];

      //comment _handler.insertUser
      // await _handler.insertUser(listReport);
    }
  }

  bool isPathNull() {
    if(imagePath == null || imagePath.isEmpty){
      return false;
    }
    return true;
  }

  Future<void> getLocation() async {
    setBusy(true);
    try{
      final userLocation = await _geolocatorService.getCurrentLocation();
      lat = userLocation.latitude;
      lng = userLocation.longitude;
      address = userLocation.addressLine;
      setBusy(false);
    }catch(e){
      setBusy(false);
      print("[Error getting location] $e");
      cameraView();
    }
  }
}