import 'dart:io';
import 'package:project_workshop_kawal_desa/constants/const.dart';
import 'package:project_workshop_kawal_desa/ui/shared/shared_style.dart';
import 'package:project_workshop_kawal_desa/ui/shared/ui_helper.dart';
import 'package:project_workshop_kawal_desa/viewmodels/AbsenViewModel.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:stacked/stacked.dart';

import 'package:flutter/services.dart';
class AbsenView extends StatefulWidget{
  @override
  _AbsenViewState createState() => _AbsenViewState();
}

class _AbsenViewState extends State<AbsenView> {
  String selectionType;
  @override
  Widget build(BuildContext context){
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp
    ]);
     // Membuat AbsenViewModel
    return ViewModelBuilder<AbsenViewModel>.reactive(
      viewModelBuilder: () => AbsenViewModel(),
      onModelReady: (model) {
        model.openLocationSetting();
        model.getTask();
      },
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          backgroundColor: color_independent,
          title: Text('Report')
        ),
        body: LoadingOverlay(
          isLoading: model.busy,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(12),
                  width: screenWidthPercent(
                    context,
                    multipleBy: 0.95
                  ),
                  child: Column(
                    children: <Widget>[
                      verticalSpaceMedium,
                      InkWell(
                        onTap: () async {
                          await model.cameraView();
                        },
                        child: Container(
                          padding: fieldPadding,
                          width: screenWidthPercent(
                            context, 
                            multipleBy: 0.83,
                          ),
                          height: screenHeightPercent(
                            context,
                            multipleBy: 0.4
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              // color: color_silverv,
                              width: 2.0
                            ),
                            borderRadius: BorderRadius.circular(5.0)
                          ),
                          child: model.isPathNull() == false ? Center(
                            child: Text(
                              "Tap",
                              style: TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                                color: color_sileverv
                              )
                            )
                          ) : Image.file(
                            File(model.imagePath),
                            fit: BoxFit.cover,
                            errorBuilder: (BuildContext context, Object exception, StackTrace stackTrace){
                              return Text('Error');
                            }
                          )
                        )
                      ),
                      verticalSpaceMedium,
                      LocationWidget(
                        title: "Lat",
                        content: "${model.lat}",
                        visible: model.isPathNull()
                      ),
                      verticalSpaceSmall,
                      LocationWidget(
                        title: 'Lng',
                        content: "${model.lng}",
                        visible: model.isPathNull()
                      ),
                      verticalSpaceMedium,
                      Visibility(
                        visible: model.isPathNull(),
                        child: Container(
                          margin: EdgeInsets.all(15.0),
                          child: DropdownButton(
                            isExpanded: true,
                            hint: Text('Choose Report Type'),
                            value: model.selectionType,
                            items: model.reportType == null ? null : model.reportType.map(
                              (value){
                                return DropdownMenuItem(
                                  child: Text(value.item2),
                                  value:value.item1
                                );
                              }
                            ).toList(),
                            onChanged: (value) {
                              setState((){
                                selectionType = value;
                              });
                              model.onChanged(value);
                              model.onReportChanged(value);
                            },
                          )
                        )
                      ),
                      verticalSpaceMedium,
                      Visibility(
                        visible: model.isPathNull(),
                        child: Text(
                          "Address",
                          style: absenNameTextStyle
                        ),
                      ),
                      verticalSpaceSmall,
                      Visibility(
                        visible: model.isPathNull(),
                        child: Text(
                          "${model.address}",
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                          style: absenContentTextStyle,
                          textAlign: TextAlign.center
                        )
                      ),
                      verticalSpaceMedium,
                      Visibility(
                        visible: model.isPathNull(),
                        child: Text(
                          "Today's Activity",
                          style: absenNameTextStyle
                        )
                      ),
                      verticalSpaceSmall,
                      Visibility(
                        visible: model.isPathNull(),
                        child: Container(
                          padding: fieldPadding,
                          width: screenWidthPercent(
                            context,
                            multipleBy: 0.9
                          ),
                          child: TextField(
                            controller: model.commentController,
                            maxLines: null,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: color_spacecafet)
                              ),
                              border: OutlineInputBorder()
                            )
                          )
                        )
                      ),
                      verticalSpaceMedium,
                      Container(
                        padding: fieldPadding,
                        width: screenWidthPercent(
                          context,
                          multipleBy: 0.9
                        ),
                        height: fieldHeight,
                        child: RaisedButton(
                          color: color_textLitle,
                          onPressed: (){
                            model.sendMessages(context);
                          },
                          child: Text(
                            "Submit Report",
                            style: textButtonTextStyle
                          )
                        )
                      ),
                      verticalSpaceSmall
                    ]
                  )
                )
              )
            )
          )
        )
      )
    );
  }
}

class LocationWidget extends StatelessWidget {
  const LocationWidget({
    Key key,
    this.title,
    this.content,
    this.visible = true
  }) : super(key: key);

  final String title;
  final String content;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text(
            "$title",
            style: absenNameTextStyle
          ),
          Text(
            "$content",
            style: absenContentTextStyle
          )
        ],
      )
    );
  }
}