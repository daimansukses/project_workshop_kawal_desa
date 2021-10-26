import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:project_workshop_kawal_desa/constants/const.dart';
import 'package:project_workshop_kawal_desa/ui/shared/shared_style.dart';
import 'package:project_workshop_kawal_desa/ui/shared/ui_helper.dart';
import 'package:project_workshop_kawal_desa/ui/widgets/text_field_on_changed_widget.dart';
import 'package:project_workshop_kawal_desa/ui/widgets/text_field_widget.dart';
import 'package:project_workshop_kawal_desa/viewmodels/sign_up_view_model.dart';

class FormPersonalData extends StatefulWidget {
  SignUpViewModel model;
  @override
  _FormPersonalDataState createState() => _FormPersonalDataState();
  FormPersonalData({this.model});
}

class _FormPersonalDataState extends State<FormPersonalData> {
  SignUpViewModel model;
  String valueDrop;
  @override
  void initState(){
    super.initState();
    model = widget.model;
  }
  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
        isLoading: model.busy,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              child: Center(
                child: Column(
                  children: <Widget>[
                    verticalSpaceSmall,
                    TextFieldWidget(
                        hintText: 'Name',
                        icon: Icons.person,
                        keyboardType: TextInputType.text,
                        isPassword: false,
                        textFieldController: model.nameController,
                        colorIcon: color_main
                    ),
                    verticalSpaceSmall,
                    TextFieldWidget(
                        hintText: 'Profesi / Jabatan / Status',
                        icon: Icons.panorama_fish_eye,
                        keyboardType: TextInputType.text,
                        isPassword: false,
                        textFieldController: model.positionController,
                        colorIcon: color_main
                    ),
                    verticalSpaceSmall,
                    TextFieldWidget(
                        hintText: 'E-Mail',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        isPassword: false,
                        textFieldController: model.emailController,
                        colorIcon: color_main
                    ),
                    verticalSpaceSmall,
                    TextFieldWidget(
                        hintText: 'No KTP / NISN / NIP',
                        icon: Icons.format_list_numbered  ,
                        keyboardType: TextInputType.text,
                        isPassword: false,
                        textFieldController: model.idCardController,
                        colorIcon: color_main
                    ),
                    verticalSpaceSmall,
                    TextFieldWidget(
                        hintText: 'Password',
                        icon: Icons.lock,
                        keyboardType: TextInputType.emailAddress,
                        isPassword: true,
                        textFieldController: model.passwordController,
                        colorIcon: color_main
                    ),
                    verticalSpaceSmall,
                    TextFieldWidget(
                        hintText: 'No Handphone',
                        icon: Icons.phone,
                        keyboardType: TextInputType.phone,
                        isPassword: false,
                        textFieldController: model.phoneNumberController,
                        colorIcon: color_main
                    ),
                    verticalSpaceSmall,
                    TextFieldOnChangedWidget(
                        hintText: 'Registration Code',
                        icon: Icons.code,
                        onChanged: (value){
                          model.units.clear();
                          if (value != null && value.toString().isNotEmpty){
                            model.company= value;
                            model.getCompanyUnit(value);
                          }
                        },
                        keyboardType: TextInputType.text,
                        isPassword: false,
                        colorIcon: color_main
                    ),
                    Visibility(
                      child: verticalSpaceSmall,
                      visible: model.changeVisibility(),
                    ),
                    Visibility(
                      visible: model.changeVisibility(),
                      child: Container(
                        padding: fieldPadding,
                        width: screenWidthPercent(context, multipleBy: 0.9),
                        height: fieldHeight,
                        child: DropdownButton(
                          isExpanded: true,
                          hint: Text("chose unit"),
                          value: valueDrop,
                          items: model.units == null
                              ? null
                              : model.units.map((value) {
                                return DropdownMenuItem(
                                  child: Text(value),
                                  value: value,
                                );
                                },
                          ).toList(),
                          onChanged: (value){
                            setState(() {
                              valueDrop = value;
                              model.onUnitChangeSelect(value);
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )
    );
  }
}
