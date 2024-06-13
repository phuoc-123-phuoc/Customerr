// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:customer_app_multistore/providers/auht_repo.dart';
import 'package:customer_app_multistore/widgets/appbar_widgets.dart';
import 'package:customer_app_multistore/widgets/snackbar.dart';
import 'package:customer_app_multistore/widgets/yellow_button.dart';
import 'package:flutter_pw_validator/flutter_pw_validator.dart';

class UpdatePassword extends StatefulWidget {
  const UpdatePassword({Key? key}) : super(key: key);

  @override
  State<UpdatePassword> createState() => _UpdatePasswordState();
}

class _UpdatePasswordState extends State<UpdatePassword> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldMessengerState> scaffoldKey =
      GlobalKey<ScaffoldMessengerState>();
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  bool checkOldPasswordValidation = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const AppBarTitle(title: 'Change Password'),
        leading: const AppBarBackButton(),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView(
            children: [
              const Text(
                'To change your password, please fill in the form below and click Save Changes',
                style: TextStyle(
                  fontSize: 20,
                  letterSpacing: 1.1,
                  color: Colors.blueGrey,
                  fontFamily: 'Acme',
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 30),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter your password';
                        }
                        return null;
                      },
                      controller: oldPasswordController,
                      decoration: passwordFormDecoration.copyWith(
                        labelText: 'Old Password',
                        hintText: 'Enter your Current Password',
                        errorText: checkOldPasswordValidation != true
                            ? 'Not a valid password'
                            : null,
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter new password';
                        }
                        return null;
                      },
                      controller: newPasswordController,
                      decoration: passwordFormDecoration.copyWith(
                        labelText: 'New Password',
                        hintText: 'Enter your New Password',
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      validator: (value) {
                        if (value != newPasswordController.text) {
                          return 'Passwords do not match';
                        } else if (value!.isEmpty) {
                          return 'Re-Enter New password';
                        }
                        return null;
                      },
                      decoration: passwordFormDecoration.copyWith(
                        labelText: 'Repeat Password',
                        hintText: 'Re-Enter your New Password',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              FlutterPwValidator(
                controller: newPasswordController,
                minLength: 8,
                uppercaseCharCount: 1,
                numericCharCount: 2,
                specialCharCount: 1,
                width: 400,
                height: 150,
                onSuccess: () {},
                onFail: () {},
              ),
              const Spacer(),
              YellowButton(
                label: 'Save Changes',
                onPressed: () async {
                  if (formKey.currentState != null &&
                      formKey.currentState!.validate()) {
                    checkOldPasswordValidation = await AuthRepo
                            .checkOldPassword(
                          FirebaseAuth.instance.currentUser!.email!,
                          oldPasswordController.text,
                        ) ??
                        false; // Kiểm tra nếu giá trị trả về là null, gán false cho checkOldPasswordValidation
                    setState(() {});

                    if (checkOldPasswordValidation) {
                      await AuthRepo.updateUserPassword(
                        newPasswordController.text.trim(),
                      ).then((_) {
                        formKey.currentState!.reset();
                        newPasswordController.clear();
                        oldPasswordController
                            .clear(); // Xóa cả oldPasswordController
                        MyMessageHandler.showSnackBar(
                          scaffoldKey,
                          'Your password has been updated',
                        );
                        Future.delayed(
                          const Duration(seconds: 3),
                        ).whenComplete(() => Navigator.pop(context));
                      }).catchError((error) {
                        print('Error updating password: $error');
                      });
                    } else {
                      print('Invalid old password');
                    }
                    print('Form valid');
                  } else {
                    print('Form not valid');
                  }
                },
                width: 0.7,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

var passwordFormDecoration = InputDecoration(
  labelText: 'Full Name',
  hintText: 'Enter your full name',
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
  enabledBorder: OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.purple, width: 1),
    borderRadius: BorderRadius.circular(6),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: const BorderSide(color: Colors.deepPurpleAccent, width: 2),
    borderRadius: BorderRadius.circular(6),
  ),
);
