import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:face_auth/common/utils/custom_snackbar.dart';
import 'package:face_auth/common/utils/custom_text_field.dart';
import 'package:face_auth/common/views/custom_button.dart';
import 'package:face_auth/constants/theme.dart';
import 'package:face_auth/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class EnterDetailsView extends StatefulWidget {
  final String image;
  final FaceFeatures faceFeatures;

  const EnterDetailsView({
    Key? key,
    required this.image,
    required this.faceFeatures,
  }) : super(key: key);

  @override
  State<EnterDetailsView> createState() => _EnterDetailsViewState();
}

class _EnterDetailsViewState extends State<EnterDetailsView> {
  bool isRegistering = false;
  final _formFieldNameKey = GlobalKey<FormFieldState>();
  final _formFieldSurnameKey = GlobalKey<FormFieldState>();
  final _formDateKey = GlobalKey<FormFieldState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _surNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: appBarColor,
        title: const Text("Add Details"),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scaffoldTopGradientClr,
              scaffoldBottomGradientClr,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomTextField(
                  formFieldKey: _formFieldNameKey,
                  controller: _nameController,
                  hintText: "Name",
                  validatorText: "Name cannot be empty",
                ),
                CustomTextField(
                  formFieldKey: _formFieldSurnameKey,
                  controller: _surNameController,
                  hintText: "Surname",
                  validatorText: "Surname cannot be empty",
                ),
                CustomTextField(
                  formFieldKey: _formDateKey,
                  controller: _dateController,
                  hintText: "2002.09.18",
                  textInputType: TextInputType.number,
                  validatorText: "Date cannot be empty",
                ),
                CustomButton(
                  text: "Register Now",
                  onTap: () {
                    if (_formFieldNameKey.currentState!.validate() &&
                        _formFieldSurnameKey.currentState!.validate() &&
                    _formDateKey.currentState!.validate()) {

                      FocusScope.of(context).unfocus();
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => const Center(
                          child: CircularProgressIndicator(
                            color: accentColor,
                          ),
                        ),
                      );

                      String userId = const Uuid().v1();
                      UserModel user = UserModel(
                        id: userId,
                        name: _nameController.text.trim().toUpperCase(),
                        image: widget.image,
                        registeredOn: DateTime.now().millisecondsSinceEpoch,
                        faceFeatures: widget.faceFeatures,
                        surName: _surNameController.text.trim().toUpperCase(),
                        date: _dateController.text.trim().toUpperCase(),
                      );

                      FirebaseFirestore.instance
                          .collection("users")
                          .doc(userId)
                          .set(user.toJson())
                          .catchError((e) {
                        log("Registration Error: $e");
                        Navigator.of(context).pop();
                        CustomSnackBar.errorSnackBar(
                            "Registration Failed! Try Again.");
                      }).whenComplete(() {
                        Navigator.of(context).pop();
                        CustomSnackBar.successSnackBar("Registration Success!");
                        Future.delayed(const Duration(seconds: 1), () {
                          //Reaches HomePage
                          Navigator.of(context)
                            ..pop()
                            ..pop()
                            ..pop();
                        });
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}